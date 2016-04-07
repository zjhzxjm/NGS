"""
Author: xujm@realbio.cn
Ver:

$ ./.py 
:

"""

import argparse
import logging

parser = argparse.ArgumentParser(description="I print fibonaccj sequence")
parser.add_argument('-s', '--start', type=int, dest='start', help='Start of the sequence', required=True)
parser.add_argument('-e', '--end', type=int, dest='end', help='End of the sequence', required=True)
parser.add_argument('-v', '--verbose', action='store_true', dest='verbose', help='Enable debug info')


def infinite_fib():
    a, b = 0, 1
    yield a
    yield b
    while True:
        logging.debug('Before calculation: a, b = %s,%s' % (a, b))
        a, b = b, a + b
        logging.debug('After calculation: a, b = %s,%s' % (a, b))
        yield b


def fib(start, end):
    for cur in infinite_fib():
        logging.debug('cur:%s, start:%s, end:%s' % (cur, start, end))
        if cur > end:
            return
        if cur >= start:
            yield cur


if __name__ == '__main__':
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(
            level=logging.DEBUG,
            format="[%(asctime)s]%(name)s:%(levelname)s:%(message)s"
        )

    for n in fib(args.start, args.end):
        print n
