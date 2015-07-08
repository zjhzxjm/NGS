#!/usr/bin/perl

# get_SRA_run_and_sample_xml.pl
#
# This script takes as input a list of SRA Run accession numbers 
# (i.e., ids of the form SRRxxxxxx) and does the following for each 
# referenced Run:
#
# 1. Downloads the XML document containing the Run's metadata from 
#    the SRA into the current working directory.
# 2. Downloads the XML documents containing the metadata for any 
#    associated Samples from the SRA into the current working 
#    directory.
# 3. Parses and checks the Run and Sample XML files and produces a 
#    simple tab-delimited metadata file, which is written into the 
#    specified metadata directory (which must exist prior to running 
#    the script), with the file suffix ".lmd".
#
# Steps 2 and 3 are not performed if the script is run with the
# retrieve_only option and the script will only download Run and
# Sample XML files that are not already present in the working
# directory.  Also note that the parsing routines are specific to the
# SRA Studies that comprise the main HMP project and in some cases
# they may contain hard-coded workarounds that are not generally
# applicable to other studies and projects.
#
# In addition to writing a series of .lmd metadata files into the 
# named metadata directory the script also prints the following 
# tab-delimited information to stdout:
#
# 1. SRA SRRxxxxxx accession number
# 2. Run Alias, as defined by the sequencing center
# 3. Instrument name (i.e., the sequencing machine used)
# 4. Center name (i.e., the sequencing center that generated the data)
# 5. dblock_filename (data block filename from the SRA metadata)
# 6. dblock member name (data block member name from the SRA metadata)
#
# The main .lmd files are also tab-delimited and contain the following
# fields:
#
#  1. Either 'NULL' or the SRA SRRxxxxxx accession number
#     NULL means that the barcode/primer are part of the Experiment but
#     are not expected to be observed in this particular Run.  If a 
#     particular barcode/primer combination _is_ expected to appear in 
#     the Run then it will appear twice in the .lmd file: once with
#     NULL in this column and once with the relevant SRRxxxxxx id.
#  2. SRA experiment accession (e.g., SRX012345)
#  3. Run alias defined by the sequencing center
#  4. Sequencing center
#  5. Experiment pool member_name
#  6. Reverse barcode description
#  7. Reverse barcode sequence
#  8. Reverse 16S primer description
#  9. Reverse primer sequence
# 10. SRA sample accession (e.g., SRS012345)
# 11. Submitted anonymized subject id
# 12. EMMES body site
#      Note that the script removes the "G_DNA_" prefix and makes the 
#       following edits:
#        Anterioir nares -> Anterior nares
#        Attached/Keritinized gingivae -> Attached/Keratinized gingiva
# 13. Submitted anonymized sample id

use strict;
use Data::Dumper;
use FileHandle;
use File::Spec;
use XML::Simple;

## globals
my $USAGE = "Usage: $0 SRR_accession_list metadata_dir/ retrieve_only > SRR-accession-to-aliases.txt";

# SRA URLs
my $SRA_RUN_URL = "http://www.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?retmode=xml&run=";
my $SRA_SAMPLE_URL = "http://www.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?retmode=xml&sample=";
# SRA retrievals can fail for a variety of reasons.  Try this many times before giving up.
my $MAX_WGET_TRIES = 4;
# sanity checking on read specs; we don't expect to allow more than this number of primer base mismatches.
my $MAX_PRIMER_MISMATCHES = 2;
my $DEBUG = 0;
# turn on Data::Dumper debugging
my $DEBUG_DATA = 0;
# start processing at the specified Run:
my $DEBUG_SKIP_TO = undef;

# hashref of downloaded and parsed samples
my $SAMPLES = {};

## input
my $srr_accs = shift || die $USAGE;
my $metadata_dir = shift || die $USAGE;
my $retrieve_only = shift;
die "metadata dir $metadata_dir does not exist or is not writable" if ((!-e $metadata_dir) || (!-d $metadata_dir) || (!-w $metadata_dir));

## main program

# read list of SRR accessions from srr_accs
my $srr_list = [];
my $afh = FileHandle->new();
$afh->open($srr_accs, 'r') || die "unable to read from $srr_accs";
my $lnum = 0;
my $na = 0;
my $nfailed = 0;
my $debug_skip_to_found = 0;
# number processed
my $np = 0;
my $all_srs_accs = {};

# interleave processing with reading the SRR ids:
RUN_LOOP:
while (my $line = <$afh>) {
    chomp($line);
    ++$lnum;
    if ($line =~ /^(SRR\d+)/) {
        ++$na;
        my $acc = $1;

        # skip to named accession if $DEBUG_SKIP_TO is set 
        if (defined($DEBUG_SKIP_TO)) {
            if (!$debug_skip_to_found) {
                if ($acc eq $DEBUG_SKIP_TO) {
                    $debug_skip_to_found = 1;
                    print STDERR "WARN - skipped to $DEBUG_SKIP_TO\n";
                }
            }
            next unless ($debug_skip_to_found)
        }

        my $run_xml = $acc . ".xml";
        my $failed += &get_xml_file($SRA_RUN_URL . $acc, $run_xml);

        # XML not retrieved
        if ($failed) {
            print STDERR "retrieval of $acc failed, removing target file $run_xml\n";
            unlink $run_xml;
            $nfailed += $failed;
            next;
        } 
        # XML retrieved (or already there)
        else {
            my $run_top = XMLin($run_xml);

            if ($DEBUG_DATA) {
                my $dd = Data::Dumper->new([$run_top]);
                print STDERR $dd->Dump() . "\n";
            }

            my $run = $run_top->{'RUN'};

            # check accession
            my $accession = $run->{'accession'};
            die "run accession in XML ($accession) doesn't match requested run accession ($acc)" if ($accession ne $acc);

            # sequencing center name
            my $center_name = $run->{'center_name'};
            die "unexpected center name ($center_name) in $acc" if ($center_name !~ /^(BI|WUGSC|Broad Institute|JCVI|BCM|Baylor College of Medicine|HMP-DACC|UMIGS)$/);

            # run alias and instrument name
            my $alias = $run->{'alias'};
            die "no alias parsed for $acc" if (!defined($alias));
            my $instrument_name = $run->{'instrument_name'};
            print STDERR "WARN - no instrument_name parsed for $acc\n" if (!defined($instrument_name));

            # data block info
            my $dblock = $run->{'DATA_BLOCK'};
            die "list-valued DATA_BLOCK entry in $acc" if (ref $dblock eq 'ARRAY');
            my $dblock_name = undef;
            my $dblock_member_name = undef;
            my $is_pooled_sub = 0;
            my $n_dblocks = scalar(keys %$dblock);

            if ($DEBUG) {
                print STDERR "DEBUG - $acc (center=$center_name) has $n_dblocks RUN DATA_BLOCKs with names=" . join(',', keys %$dblock) . "\n";
            }

            next if ($retrieve_only);

            # A pooled submission will have multiple RUN DATA_BLOCKS, with (at least for the JCVI submissions) some
            # substring of the RUN alias as the consistent name of the DATA_BLOCKs.  A non-pooled submission will 
            # have a single DATA_BLOCK with at least the following fields: FILES, member_name
            if (defined($dblock->{'FILES'}) || defined($dblock->{'member_name'})) {
                $dblock_name = $dblock->{'name'}; # 454 run id?
                $dblock_member_name = $dblock->{'member_name'};
                die "no RUN DATA_BLOCK member_name found in $acc" if (!defined($dblock_member_name));
            } 
            # pooled submission: verify that the RUN alias is used as the DATA_BLOCK name, otherwise a closer look
            # might be warranted (but only a warning will be printed here)
            else {
                my $nn = scalar(keys %$dblock);
                die "unexpected number ($nn instead of 1) of RUN DATA_BLOCK names for a presumed pooled submission" if ($nn != 1);
                my $run_alias = $run->{'alias'};
                my $run_alias_found = 0;

                if (defined($dblock->{$run_alias})) {
                    $run_alias_found = 1;
                }
                # handle case where run alias has a date appended
                # e.g., <RUN alias="GGBO4VW 06-16-2010"... <DATA_BLOCK name="GGBO4VW"...
                elsif ($run_alias =~ /^(\S+)\s\d{2}\-\d{2}\-\d{4}$/) {
                    $run_alias = $1;
                    $run_alias_found = 1 if (defined($dblock->{$run_alias}));
                }
                # handle case where run alias has a serial number (01,02,etc.) appended 
                # e.g., <RUN alias="GGBO4VW01 06-16-2010"... <DATA_BLOCK name="GGBO4VW"...
                # e.g., <RUN alias="GGBO4VW02"... <DATA_BLOCK name="GGBO4VW"...
                if ((!$run_alias_found) && ($run_alias =~ /^(\S+)0\d$/)) {
                    $run_alias = $1;
                    $run_alias_found = 1 if (defined($dblock->{$run_alias}));
                }
                # handle case where run alias looks like this:
                # 'alias' => 'HUMAN METAGENOME 2ZC05V5V3-BA-01-640 Experiment GJKK7LC01',
                if ((!$run_alias_found) && ($run_alias =~ /^HUMAN METAGENOME \S+ Experiment (\S+)$/)) {
                    $run_alias = $1;
                    $run_alias_found = 1 if (defined($dblock->{$run_alias}));
                }
                
                my @dbkeys = keys %$dblock;
                my $nk = scalar(@dbkeys);
                print STDERR "WARN - possible pooled submission found for $acc (center=$center_name)\n";
                $is_pooled_sub = 1;
                die "DATA_BLOCK has $nk key(s)" if ($nk != 1);

                if (!$run_alias_found) {
                    print STDERR "WARN - unable to find matching RUN alias (alias=$run->{'alias'}) for DATA_BLOCKs in $acc (center=$center_name)\n";
                    $run_alias = $dbkeys[0];
                }
                $dblock = $dblock->{$run_alias};
                $dblock_name = $dblock->{$run_alias};
                # $dblock_member_name undef means everything has been pooled under 1 run (i.e., legacy encoding)
            }

            my $dblock_files = $dblock->{'FILES'};
            die "list-valued DATA_BLOCK FILES entry in $acc" if (ref $dblock_files eq 'ARRAY');
            my $dblock_file = $dblock_files->{'FILE'};
            my @dblock_filenames = ();

            if (ref $dblock_file eq 'ARRAY') {
                print STDERR "WARN - list-valued DATA_BLOCK FILES FILE entry in $acc\n";
                @dblock_filenames = map {$_->{'filename'}} @$dblock_file;
            } else {
                push(@dblock_filenames, $dblock_file->{'filename'});
            }

            my $ndbf = scalar(@dblock_filenames);
            die "no RUN DATA_BLOCK filenames found in $acc" if ($ndbf == 0);
            
            # experiment
            my $experiment = $run_top->{'EXPERIMENT'};
           
            # have EXPERIMENT_REF but no top-level EXPERIMENT (normally both are present)
            if (!defined($experiment) && defined($run->{'EXPERIMENT_REF'})) {
              my $eref = $run->{'EXPERIMENT_REF'};
              my $refacc = $eref->{'accession'};
              my $refname = $eref->{'refname'};
              die "undefined EXPERIMENT_REF->accession" if (!defined($refacc));
              die "undefined EXPERIMENT_REF->refname" if (!defined($refname));
              print STDERR "ERROR - failed on $acc due to missing EXPERIMENT\n";
              next RUN_LOOP;
            }

            my $exp_accn = $experiment->{'accession'};
            die "malformed experiment accession for run $accession" if ($exp_accn !~ /^SRX\d+$/);

            # DESIGN->SPOT_DESCRIPTOR 
            my $spot_desc = $experiment->{'DESIGN'}->{'SPOT_DESCRIPTOR'};
            my $read_spec = $spot_desc->{'SPOT_DECODE_SPEC'}->{'READ_SPEC'};
            die "read_spec is not array-valued in $acc" if (ref $read_spec ne 'ARRAY');

            # EXPECTED_BASECALL_TABLE->BASECALL will map barcode to read_group_tag
            # DESIGN->SAMPLE_DESCRIPTOR will map read_group_tag to SRS accession and refname
            my $sample_desc = $experiment->{'DESIGN'}->{'SAMPLE_DESCRIPTOR'};
            my $exp_pool_members = [];
            my $pool_members = $sample_desc->{'POOL'}->{'MEMBER'};
            $pool_members = [$pool_members] if (ref $pool_members ne 'ARRAY');
            my $pool_member_name_to_acc = {};
            foreach my $pmem (@$pool_members) {
                # e.g., 
                #'proportion' => '0.01298701',
                #'refcenter' => 'NCBI',
                #'READ_LABEL' => [
                #                 {
                #                     'read_group_tag' => 'Abuja',
                #                     'content' => 'barcode'
                #                     },
                #                 {
                #                     'read_group_tag' => 'V5-V3',
                #                     'content' => 'primer'
                #                     }
                #                 ],
                #'member_name' => 'Abuja_0092014601',
                #'accession' => 'SRS017677',
                #'refname' => '700034692'
                #},
                push(@$exp_pool_members, $pmem);
                die "duplicate pool member name " . $pmem->{'member_name'} if (defined($pool_member_name_to_acc->{$pmem->{'member_name'}}));
                $pool_member_name_to_acc->{$pmem->{'member_name'}} = $pmem->{'accession'};
            }

            # run contains one or more pool members
            my $run_pools = $run->{'Pool'};
            if (!defined($run_pools)) {
                # a number of entries have missing Pool elements within the <RUN> block
                # and there's no discernible pattern thus far i.e., they all look almost
                # identical to other entries that _do_ have this information
                # if it's missing we'll note the fact and attempt to recreate it, at least
                # in the case where the run corresponds to a single pool member
                my ($tb, $ts) = map {$run->{$_}} ('total_bases', 'total_spots');
                die "got total_bases '$tb' for $acc" unless ($tb =~ /^\d+$/);
                die "got total_spots '$ts' for $acc" unless ($ts =~ /^\d+$/);

                # special case for BI "UNMATCHED" runs, where the run pool members should be set to all the pool members
                # note that it might be cleaner to handle this in a downstream step; the metadata is what it is
                if (($dblock_member_name eq '') && ($alias =~ /unmatched/i) && ($run->{'run_center'} eq 'BI')) {
                  my @rp = map { {'Member' => { 'member_name' => $_, 'accession' => $pool_member_name_to_acc->{$_} }}} keys %$pool_member_name_to_acc;
                  $run_pools = \@rp;
                } else {
                  my $srs_acc = $pool_member_name_to_acc->{$dblock_member_name};
                  if (!defined($srs_acc)) {
                    die "couldn't find pool member accession for data block member name '$dblock_member_name' in $acc with pool members=" . join(',', keys %$pool_member_name_to_acc);
                  }

                  my $pm = {
                            'bases' => $tb,
                            'spots' => $ts,
                            'accession' => $srs_acc,
                            'member_name' => $dblock_member_name,
                           };
                  
                  $run_pools = { 'Member' => $pm };
                  print STDERR "WARN - inserted missing RUN Pool with member_name=$dblock_member_name, accession=$srs_acc for $acc\n";
                }
            }

            my $run_pool_members = [];
            if (ref $run_pools ne 'ARRAY') { $run_pools = [$run_pools]; }
            foreach my $pool (@$run_pools) {
                my $member = $pool->{'Member'};
                die "pool has keys other than 'Member' for $acc" if (join(',', keys %$pool) ne 'Member');
                my $rpm = undef;

                # this should only happen for pooled submissions:
                if (ref $member eq 'ARRAY') {
                    if (!$is_pooled_sub) {
                        my $nps = scalar(@$member);

                        # special case for problem seen in SRR208169, for example, where the members look like this (note bogus base counts):
                        #
                        # 'spots' => '913',
                        # 'Pool' => {
                        #    'Member' => [
                        #                 {
                        #                     'bases' => '18',
                        #                     'spots' => '18',
                        #                     'accession' => 'SRS026543',
                        #                     'member_name' => ''
                        #                     },
                        #                 {
                        #                     'bases' => '895',
                        #                     'spots' => '895',
                        #                     'accession' => 'SRS013249',
                        #                     'member_name' => 'Jerusalem_AACAACTC'
                        #                     }
                        #                 ]
                        #                 },
                        #                     
                        if (($nps == 2) && ($member->[0]->{'accession'} eq 'SRS026543') && ($member->[0]->{'member_name'} eq '') && ($member->[1]->{'member_name'} ne '')) {
                            if ($member->[1]->{'bases'} == $member->[1]->{'spots'}) {
                                print STDERR "ERROR - spots == bases for pool member " . $member->[1]->{'member_name'} . " in $acc\n";
                            }
                            $is_pooled_sub = 1;
                        }
                        else {
                            die "multi-valued Pool Member found for $acc, which was not recognized as a pooled submission";
                        }
                    }
                    $rpm = $member;
                    push(@$run_pool_members, @$member);
                } else {
                    $rpm = [$member];
                    push(@$run_pool_members, $member);
                }
                
                foreach my $mem (@$rpm) {
                    my $srs_acc = $mem->{'accession'};
                    die "pool member accession ($srs_acc) is not an SRS sample accession for $acc" if ($srs_acc !~ /^SRS\d+$/);
                    $all_srs_accs->{$srs_acc} = 1;
                }
            }
            foreach my $dblock_filename (@dblock_filenames) {
                print join("\t", $accession, $alias, $instrument_name, $center_name, $dblock_filename, $dblock_member_name) . "\n";
            }
            my $dblock_filename = (scalar(@dblock_filenames) == 1) ? $dblock_filenames[0] : undef;

            # simplified data structure for the run
            my $run = {
                # RUN-related info.
                'accession' => $accession,
                'center' => $center_name,
                'alias' => $alias,
                'instrument_name' => $instrument_name, # may be undef
                'dblock_name' => $dblock_name,
                'dblock_filename' => $dblock_filename,
                'dblock_filenames' => \@dblock_filenames,
                'dblock_member_name' => $dblock_member_name, # undef for pooled submissions
                'is_pooled_sub' => $is_pooled_sub,
                'run_pool_members' => $run_pool_members, # RUN Pools, with Member => level stripped away
                
                # EXPERIMENT-related info
                'exp_accn' => $exp_accn,
                'exp_pool_members' => $exp_pool_members,
                'spot_desc' => $spot_desc,
                'sample_desc' => $sample_desc,
            };

            ++$np;
            &process_run($run);
        }
    }
}
$afh->close();

print STDERR "processed XML run info for $np/$na SRR accessions, $nfailed retrieval(s) failed\n";
exit($nfailed);

## subroutines

sub get_sample {
    my($srs_acc) = @_;

    # check $SAMPLES
    my $sample = $SAMPLES->{$srs_acc};
    return $sample if (defined($sample));
    
    # download file if necessary
    my $sample_xml = $srs_acc . ".xml";
    my $sample = undef;

    if (!-e $sample_xml) {
        my $num_tries = 0;
        
        # enforce request delay as per NCBI's web API access guidelines
        sleep(2);

        # retry a couple of times if an ERROR like this one is returned:
        #
        #  sample for SRS064446 $VAR1 = {
        #          'ERROR' => {
        #                     'number' => '1205',
        #                     'content' => 'Transaction (Process ID 149) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.',
        #                     'public' => 'yes',
        #                     'severity' => '13',
        #                     'procedure' => 'GET_SamplePackage_xml',
        #                     'line' => '44'
        #                   },
        #          'accession' => 'SRS064446'
        #        };
        #
        while ($num_tries < $MAX_WGET_TRIES) {
            ++$num_tries;
            my $url = $SRA_SAMPLE_URL . $srs_acc;
            my $failed = &get_xml_file($url, $sample_xml);
            die "failed to retrieve $url into $sample_xml" if ($failed);
            $sample = XMLin($sample_xml);
            if (defined($sample->{'ERROR'})) {
                print STDERR "WARN - retrieval try #${num_tries} for $sample_xml failed - " . $sample->{'ERROR'}->{'content'} . "\n";
                unlink $sample_xml;
                sleep(60 * $num_tries);
            } else {
                last;
            }
        } 
    } 

    # parse sample XML and add it to $SAMPLES
    $sample = XMLin($sample_xml) if (!defined($sample));
    $SAMPLES->{$srs_acc} = $sample;
    return $sample;
}

sub get_xml_file {
    my($url, $file) = @_;
    my $failed = 0;
    
    # reuse existing files
    if (-e $file) { 
        print STDERR "INFO - $file already downloaded\n";
    } 
    else {
        my $cmd = "wget '$url' -O $file";
        system($cmd);
        
        if ($? == -1) {
            print STDERR "wget command failed to execute: $!\n";
            $failed = 1;
        }
        elsif ($? & 127) {
            print STDERR "wget command died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without';
            $failed = 1;
        }
        else {
            my $exitval = $? >> 8;
            if ($exitval != 0) {
                print STDERR "wget command exited with value $exitval\n";
                $failed = 1;
            }
        }
    }
    return $failed;
}

sub process_run {
    my($run) = @_;
    my($accn, $center, $alias, $exp_accn, $is_pooled_sub, $exp_pool_members, $run_pool_members, $spot_desc, $sample_desc) = 
        map {$run->{$_}} ('accession', 'center', 'alias', 'exp_accn', 'is_pooled_sub', 'exp_pool_members', 'run_pool_members', 'spot_desc', 'sample_desc');

    print STDERR "INFO - processing $accn\n";

    # parse/check spot descriptor
    # NOTE: this is a hard-coded dissection of the read spec that is specific to this study/project
    my $dspec = $spot_desc->{'SPOT_DECODE_SPEC'};
    my $reads_per_spot = $dspec->{'NUMBER_OF_READS_PER_SPOT'};
    my $rspec = $dspec->{'READ_SPEC'};
    my $nrs = scalar(@$rspec);
    $reads_per_spot = $nrs if (!defined($reads_per_spot));

    die "unexpected number of reads per spot ($reads_per_spot) for $accn" if ($reads_per_spot != 4);
    die "READ_SPEC length ($nrs) doesn't match reads per spot ($reads_per_spot)" if ($nrs != $reads_per_spot);
    my @srspec = sort { $a->{'READ_INDEX'} <=> $b->{'READ_INDEX'} } @$rspec;

    # -------------------------------------------------------------------------------
    # READ_SPEC
    # -------------------------------------------------------------------------------
    
    # 1 - adapter
    my $adapter_eb = $srspec[0]->{'EXPECTED_BASECALL'};
    $adapter_eb = $srspec[0]->{'EXPECTED_BASECALL_TABLE'}->{'BASECALL'}->{'content'} if (!defined($adapter_eb));
    die "unexpected adapter READ_CLASS for $accn" unless ($srspec[0]->{'READ_CLASS'} eq 'Technical Read');
    die "unexpected adapter READ_TYPE for $accn" unless ($srspec[0]->{'READ_TYPE'} eq 'Adapter');
    # some runs (e.g., SRR166840) don't specify _what_ the adapter is
    if (!defined($adapter_eb)) {
      my $adapter_spec = $dspec->{'ADAPTER_SPEC'};
      if (defined($adapter_spec)) {
        print STDERR "ERROR - unexpected adapter ($adapter_spec) EXPECTED_BASECALL/BASECALL for $accn\n" unless ($adapter_spec eq 'TCAG');
      } else {
        die "$accn does not define ADAPTER_SPEC, EXPECTED_BASECALL, or EXPECTED_BASECALL_TABLE for Adapter sequence";
      }
    } else {
      print STDERR "ERROR - unexpected adapter ($adapter_eb) EXPECTED_BASECALL/BASECALL for $accn\n" unless ($adapter_eb eq 'TCAG');
    }

    # 2 - barcode
    die "unexpected barcode READ_CLASS for $accn" unless ($srspec[1]->{'READ_CLASS'} eq 'Technical Read');
    die "unexpected barcode READ_TYPE for $accn" unless ($srspec[1]->{'READ_TYPE'} eq 'BarCode');
    die "unexpected barcode READ_LABEL for $accn" unless ($srspec[1]->{'READ_LABEL'} eq 'barcode');
    my $table = $srspec[1]->{'EXPECTED_BASECALL_TABLE'}->{'BASECALL'};
    # some runs have only a single barcode in their SPOT_DECODE_SPEC
    if (ref $table ne 'ARRAY') {
#        print STDERR "WARN - $accn has only a single BASECALL in its barcode EXPECTED_BASECALL_TABLE\n";
        $table = [$table];
    }
    my $barcode2read_group_tag = {};
    my $read_group_tag2barcode = {};
    foreach my $t (@$table) {
        my($rgt, $c, $mma, $mmi, $me) = map {$t->{$_}} ('read_group_tag', 'content', 'min_match', 'max_mismatch', 'match_edge');
        die "invalid read_group_tag in barcode table for $accn" unless ($rgt =~ /\S+/);
        die "invalid barcode in barcode table for $accn" unless ($c =~ /^[ACTG]+$/);
        my $cl = length($c);
        print STDERR "WARN - min_match=$mma for barcode of length $cl in $accn\n" if ($cl != $mma);
        print STDERR "WARN - max_mismatch=$mmi for barcode of length $cl in $accn\n" unless ($mmi == 0);
        die "match_edge != full for barcode in $accn" unless ($me eq 'full');
        die "duplicate barcode ($c) in barcode table for $accn" if (defined($barcode2read_group_tag->{$c}));
        $barcode2read_group_tag->{$c} = $rgt;
        die "duplicate read_group_tag ($rgt) in barcode table for $accn" if (defined($read_group_tag2barcode->{$rgt}));
        $read_group_tag2barcode->{$rgt} = $c;
    }
    print STDERR "DEBUG - read " . scalar(keys %$barcode2read_group_tag) . " barcode->read_group_tag mapping(s)\n";

    # 3 - primer
    die "unexpected primer READ_CLASS for $accn" unless ($srspec[2]->{'READ_CLASS'} eq 'Technical Read');
    die "unexpected primer READ_TYPE for $accn" unless ($srspec[2]->{'READ_TYPE'} eq 'Primer');
    die "unexpected primer READ_LABEL for $accn" unless ((!defined($srspec[2]->{'READ_LABEL'})) || ($srspec[2]->{'READ_LABEL'} =~ /^(rRNA_)?primer/));
    my $table = $srspec[2]->{'EXPECTED_BASECALL_TABLE'}->{'BASECALL'};
    $table = [$table] if (ref $table ne 'ARRAY');
    my $primer2read_group_tag = {};
    my $read_group_tag2primer = {};
    foreach my $t (@$table) {
        my($rgt, $c, $mma, $mmi, $me) = map {$t->{$_}} ('read_group_tag', 'content', 'min_match', 'max_mismatch', 'match_edge');
        die "invalid read_group_tag in primer table for $accn" unless ($rgt =~ /\S+/);
        die "invalid primer in primer table for $accn" unless ($c =~ /^[ACTGMRY]+$/);
        my $cl = length($c);
        print STDERR "WARN - min_match=$mma for primer of length $cl in $accn" if ($mma < ($cl - $MAX_PRIMER_MISMATCHES));
        # unclear whether this is legal; perhaps setting (min_match + max_mismatch) > length is allowing for mismatches _and_ insertions?
        print STDERR "WARN - max_mismatch=$mmi for primer of length $cl in $accn\n" unless ($mmi <= $MAX_PRIMER_MISMATCHES);
        die "match_edge != full for primer in $accn" unless ($me eq 'full');
        die "duplicate primer ($c) in primer table for $accn" if (defined($primer2read_group_tag->{$c}));
        $primer2read_group_tag->{$c} = $rgt;
        if (defined($read_group_tag2primer->{$rgt})) {
          my $old_c = $read_group_tag2primer->{$rgt};
          if ($old_c eq $c) {
            print STDERR "WARN - duplicate read_group_tag ($rgt) in primer table for $accn maps to $c\n";
          } else {
            print STDERR "ERROR - duplicate read_group_tag ($rgt) in primer table for $accn.  NEW VALUE $c WILL OVERRIDE OLD VALUE $old_c\n";
          }
        }
        $read_group_tag2primer->{$rgt} = $c;
    }
    print STDERR "DEBUG - read " . scalar(keys %$primer2read_group_tag) . " primer->read_group_tag mapping(s)\n";
    print STDERR "INFO - multiple primers found for $accn\n" if (scalar(keys %$primer2read_group_tag) > 1);
    # TODO - check that read group is one of a prescribed set?

    # 4 - 16S sequence primers
    die "unexpected primer READ_CLASS for $accn" unless ($srspec[3]->{'READ_CLASS'} eq 'Application Read');
    die "unexpected primer READ_TYPE for $accn" unless ($srspec[3]->{'READ_TYPE'} eq 'Forward');

    # generate file with the metadata for this one SRA run and its associated experiment
    my $md_file = File::Spec->catfile($metadata_dir, $accn . ".lmd");
    my $md_fh = FileHandle->new();
    $md_fh->open(">$md_file") || die "unable to write to $md_file";

    # -------------------------------------------------------------------------------
    # Sample POOL_MEMBERS
    # -------------------------------------------------------------------------------
    my $accn2epm = {};
    foreach my $pmem (@$exp_pool_members) {
        my($rl, $mn, $sample_acc, $rn) = map { $pmem->{$_} } ('READ_LABEL', 'member_name', 'accession', 'refname');
        # lookup sample for accession
        die "found non-SRS accession for experiment pool member in $accn" if ($sample_acc !~ /^SRS\d+$/);
        my $sample = &get_sample($sample_acc);
        $pmem->{'sample'} = $sample;

        if ($DEBUG_DATA) {
            my $dd = Data::Dumper->new([$sample]);
            print STDERR "sample for $sample_acc " . $dd->Dump(). "\n";
        }

        # parse tags and values from $sample_att
        my $sample_att = $sample->{'SAMPLE_PACKAGE'}->{'SAMPLE'}->{'SAMPLE_ATTRIBUTES'}->{'SAMPLE_ATTRIBUTE'};
        my $sample_name = $sample->{'SAMPLE_PACKAGE'}->{'SAMPLE'}->{'SAMPLE_NAME'}->{'COMMON_NAME'};

        # rules are different for some of the HMP controls
        my($orep, $ssamid, $ssubid, $bsite) = (undef, undef, undef, undef);

        if ($sample_name =~ /^(water blank|positive control)$/) {
            $bsite = $sample_name;
            $ssubid = '';
            $ssamid = '';
        } 
        else {
            die "sample $accn for $accn has no SAMPLE_ATTRIBUTE entry" if (!defined($sample_att));
            my $sample_att_h = {};
            foreach my $sa (@$sample_att) {
                my($v, $t) = map {$sa->{$_}} ('VALUE', 'TAG');
                die "duplicate sample tag '$t' for $accn" if (defined($sample_att_h->{$t}) && ($t ne 'gap_study_version'));
                $sample_att_h->{$t}  = $v;
            }
            
            ($orep, $ssamid, $ssubid, $bsite) = map { $sample_att_h->{$_} } ('original_repository', 'submitted_sample_id', 'submitted_subject_id', 'body_site');
            # JC 2011/06/08 - accomodate SRA/HMP schema changes
            $orep = $sample_att_h->{'biospecimen repository'} if (!defined($orep));
            $ssamid = $sample_att_h->{'submitted sample id'} if (!defined($ssamid));
            $ssubid = $sample_att_h->{'submitted subject id'} if (!defined($ssubid));
            $bsite = $sample_att_h->{'body site'} if (!defined($bsite));
            # JC 2011/09/26 - more SRA/HMP schema changes
            $ssubid = $sample_att_h->{'study_subject_id'} if (!defined($ssubid));
            $bsite = $sample_att_h->{'analyte_type'} if (!defined($bsite));
            # TODO - check that these terms adhere to project-specific controlled vocabs
            die "non-EMMES sample id for $accn ($orep)" if ($orep ne 'EMMES_HMP');
            die "illegal submitted_sample_id ($ssamid) for $accn" if ($ssamid !~ /^\d+$/);
            die "illegal submitted_subject_id ($ssubid) for $accn" if ($ssubid !~ /^\d+$/);
            die "no body_site for $accn" if (($bsite !~ /\S+/ || ($bsite eq 'NULL')));
        }
            
        # fix spelling erroirs and standardize vocabulary
        $bsite =~ s/Anterioir nares/Anterior nares/;
        $bsite =~ s/^G_DNA_//;
        $bsite =~ s/Attached\/Keritinized gingivae/Attached\/Keratinized gingiva/;

        # read primer/barcode combination for this group
        my $rlabel = $pmem->{'READ_LABEL'};
        my $mname = $pmem->{'member_name'};
        die "no member name for pool member in $accn" if (!defined($mname));
        my $rls = {};
        foreach my $rl (@$rlabel) {
            my($rgt, $c) = map {$rl->{$_}} ('read_group_tag', 'content');
            if (($c eq 'primer') || ($c eq 'rRNA_primer')) {
              my $list = $rls->{$c};
              $list = $rls->{$c} = [] if (!defined($list));
              push(@$list, $rgt);
            } else {
              die "duplicate pool read_label $c for $accn" if (defined($rls->{$c}));
              $rls->{$c} = $rgt;
            }
        }

        my $barcode_tag = $rls->{'barcode'};
        my $primer_tags = $rls->{'primer'} || $rls->{'rRNA_primer'};

        # lookup actual barcode and primer from read_spec expected basecall tables from tags
        my $barcode_seq = $read_group_tag2barcode->{$barcode_tag};
        die "failed to lookup barcode seq for tag $barcode_tag in $sample_acc" if (!defined($barcode_seq));
        my $primer_seqs = [];
        foreach my $pt (@$primer_tags) {
          my $primer_seq = $read_group_tag2primer->{$pt};
          die "failed to lookup primer seq for tag $pt in $sample_acc" if (!defined($primer_seq));
          push(@$primer_seqs, $primer_seq);
        }

        # print all the lines from the experiment with the experiment accession in the first column
        my $npt = scalar(@$primer_tags);
        for (my $p = 0;$p < $npt;++$p) {
          my $line = join("\t", $exp_accn, $alias, $center, $mname, $barcode_tag, $barcode_seq, $primer_tags->[$p], $primer_seqs->[$p], $sample_acc, $ssubid, $bsite, $ssamid);
          $pmem->{'lines'} = [] if (!defined($pmem->{'lines'}));
          push(@{$pmem->{'lines'}}, $line);
          $md_fh->print("NULL\t". $line . "\n");
        }

        # this can happen for positive controls separated by V-region
        # make a list and deal with it on the lookup side
        if (defined($accn2epm->{$sample_acc})) {
            print STDERR "WARN - duplicate accession ($sample_acc) for experiment pool member in $accn with alias=$alias\n";
            my $cval = $accn2epm->{$sample_acc};
            if (ref $cval eq 'ARRAY') {
                push(@$cval, $pmem);
            } else {
                $accn2epm->{$sample_acc} = [$cval, $pmem];
            }
        } else {
            $accn2epm->{$sample_acc} = $pmem;
        }
    }

    # -------------------------------------------------------------------------------
    # Run POOL_MEMBERS (a subset of the above)
    # -------------------------------------------------------------------------------
    my $is_hi_pri = 0;

    # print the relevant lines from the experiment with the run accession in the first column
    foreach my $rpm (@$run_pool_members) {
        my($bases, $spots, $acc, $rn) = map { $rpm->{$_} } ('bases', 'spots', 'accession', 'member_name');
        my $epm = $accn2epm->{$acc};

        # if multiple samples found, see whether member_name gives a unique match
        if (ref $epm eq 'ARRAY') {
            my $npm = scalar(@$epm);
            print STDERR "WARN - SRS accession $acc maps to multiple pool members ($npm) for $accn\n";
            my $member_name= $rpm->{'member_name'};
            my $new_epm = [];
            
            foreach my $ep (@$epm) {
                push(@$new_epm, $ep) if ($ep->{'member_name'} eq $member_name);
            }

            if (scalar(@$new_epm) == 1) {
                print STDERR "INFO - SRS accession $acc disambiguated by member_name $member_name for $accn\n";
                $epm = $new_epm->[0];
            } else {
                die "unable to disambiguate using member_name=$member_name";
            }
        }

        # this can happen for BI "UNMATCHED" groups
        if (!defined($epm)) {
            if ($alias =~ /_UNMATCHED$/) {
                print STDERR "INFO - no experiment pool member found for acc=$acc in $accn with alias=$alias\n";
            } else {
                my $sample = &get_sample($acc);
                my $sample_alias = $sample->{'SAMPLE_PACKAGE'}->{'SAMPLE'}->{'alias'};
                
                if ($sample_alias =~ /unidentified-protected/) {
                    print STDERR "INFO - no experiment pool member found for acc=$acc in $accn with alias=$alias\n";
                } else {
                    die "failed to get experiment pool member for acc=$acc in $accn, with alias=$alias";
                }
            }
        } else {
            foreach my $line (@{$epm->{'lines'}}) {
              $md_fh->print($accn . "\t" . $line . "\n");
            }
            if ($epm->{'is_high_priority'}) {
                $is_hi_pri = 1;
            }
        }
    }

    print STDERR "INFO - high priority run: $accn \n" if ($is_hi_pri);
    $md_fh->close();
}
