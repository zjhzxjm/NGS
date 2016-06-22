# -*- coding: utf-8 -*-
"""
Author: xujm@realbio.cn
Ver:1.0
init
"""

import os
import re
import subprocess
import json
import argparse
import logging
import top.api
import settings

parser = argparse.ArgumentParser(description="")
parser.add_argument('-p', '--phone', dest='phone', type=str, help='Send sms alert to this phone', required=True)
parser.add_argument('-v', '--verbose', action='store_true', dest='verbose', help='Enable debug info')
parser.add_argument('--version', action='version', version='1.0')


class SmsTool:
    def __init__(self, phone, hostname, d_temp):
        self.phone = phone.strip()
        self.hostname = hostname
        self.d_temp = d_temp

    def temp_warn(self):
        appkey = settings.ALIDAYU_APPKEY
        secret = settings.ALIDAYU_SECRET
        logging.debug('sms config: {0} {1}, in_temp {2}'.format(appkey, secret, self.d_temp['in_temp']))
        req = top.api.AlibabaAliqinFcSmsNumSendRequest()
        req.set_app_info(top.appinfo(appkey, secret))
        # req.extend = "123456"
        req.sms_type = "normal"
        req.sms_free_sign_name = "锐翌集群"
        req.sms_param = json.dumps({'hostname': self.hostname, 'in_temp': str(self.d_temp['in_temp']),
                                    'ex_temp': str(self.d_temp['ex_temp'])})
        req.rec_num = self.phone
        req.sms_template_code = "SMS_10845500"
        try:
            resp = req.getResponse()
            return 1
        except Exception as e:
            logging.debug('sms error {0}'.format(e))
            return 0


class IpmiTool:
    def __init__(self, hostname):
        self.hostname = hostname

    def get_temp(self):
        handle = os.popen('/opt/rocks/bin/rocks run host {0} "ipmitool -c sdr type temperature"'.format(self.hostname))
        for i in handle:
            if re.search('^FP', i) or re.search('^Inlet', i):
                logging.debug('inlet line {0}'.format(i))
                in_temp = int(i.split(',')[1])
            elif re.search('^MB', i) or re.search('^Exhaust', i):
                logging.debug('exhaust line {0}'.format(i))
                ex_temp = int(i.split(',')[1])
        return {'in_temp': in_temp, 'ex_temp': ex_temp}


if __name__ == '__main__':
    args = parser.parse_args()
    phone = args.phone
    hosts = ['nas-0-1', 'nas-0-2', 'nas-0-3', 'nas-0-4', 'nas-0-5', 'nas-0-6', 'nas-0-7', 'nas-0-8', 'nas-0-t',
             'data-0-1', 'data-0-2', 'data-0-3', 'data-0-4', 'data-0-6', 'data-0-7',
             'nas-1-1']
    ex_temp_max = 45
    in_temp_max = 30
    sms_done_file = '/data_center_01/home/xujm/logs/sms.done'
    if args.verbose:
        logging.basicConfig(
            level=logging.DEBUG,
            format="[%(asctime)s]%(name)s:%(levelname)s:%(message)s",
            filename='debug.log'
        )
    else:
        logging.basicConfig(
            level=logging.INFO,
            format="[%(asctime)s]%(name)s:%(levelname)s:%(message)s",
            filename='/data_center_01/home/xujm/logs/TempMoniInfo.log'
        )

    for host in hosts:
        obj_ipmi = IpmiTool(host)
        d_temp = obj_ipmi.get_temp()
        if d_temp['ex_temp'] >= ex_temp_max or d_temp['in_temp'] >= in_temp_max:
            if not os.path.exists(sms_done_file):
                obj_sms = SmsTool(phone, host, d_temp)
                recode = obj_sms.temp_warn()
                if recode:
                    logging.debug('touch sms.done ok: {0}'.format(recode))
                    subprocess.call(['touch', sms_done_file])
                    break
                else:
                    logging.debug('SMS not send')
            logging.info('Temp:{0} - {1} - {2}'.format(host, d_temp['in_temp'], d_temp['ex_temp']))
        else:
            recode = subprocess.call(['rm', sms_done_file])
            logging.debug('rm sms.done return code: {0}'.format(recode))
