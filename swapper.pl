#!/usr/local/bin/perl
##########################################################################
# NAME: swapper                                                          #
# LOCATION: /home/raven/jfkrone                                          #
# DATE: 30 Jan 98                                                        #
# TYPE: PERL script                                                      #
# REFERENCES: Perl manual pages                                          #
# PROGRAMMER: jfkrone@fsk.f.nsa, SrA Jason F. Kronemeyer, 952-4263       #
# LANGUAGE: PERL 5                                                       #
# INPUT: Search and Replace strings, directory tree.                     #
# OUTPUT: Original files with changes.                                   #
# PURPOSE: Targeted towards www directories for mass changes to all text #
#          files in a directory tree.                                    #
# SHELL RQMTS: PERL must be installed on network.                        #
# COMMENTS:                                                              #
#                                                                        #
# CHANGE LIST:                                                           #
# DATE    /   PGMR    / CHANGES MADE                                     #
# 30 Jan 98  jfkrone   Original program                                  #
# 26 Jul 20  jfkrone   Version Conrtol added                             # 
##########################################################################

#  Check the command line to verify the correct amount of arguments.
#  Looks for search string, replace string, and at least one directory tree.
#  If not there invokes Usage subroutine and exits.
if( scalar( @ARGV ) < 3 ) {
       &Usage;
       exit;
}
#  Sets the $SEARCH and $REPLACE string to $ARGV[0] and $ARGV[1]
my $SEARCH = shift @ARGV;
my $REPLACE = shift @ARGV;
#  Feeds the top of the directory tree and all remaining directories
#  to the Replacer Subroutine along with the search and replace strings
foreach( @ARGV ) {
        &Replacer( $SEARCH, $REPLACE, $_ );
}
sub Usage {
        print "Usage: $0 [search string]  [replace string] dirl [dir2 .. dirn]\n";
}
############################################################################
#                                                                          #
#  The Replacer subroutine is the meat of this script.  It is a recursive  #
#  subroutine that searchs down a directory tree and performs search and   #
#  replace on all text files in the tree. Routine will ignore all symbolic #
#  links.                                                                  #
#                                                                          #
############################################################################
sub Replacer {
        my( $SEARCH_STRING, $REPLACE_STRING, $FILENAME ) = @_;
        local( *INFILE, *DIR );
        my( @OUT );
# Check to see if file is a text flle
        if( -T $FILENAME ) {
                print "$FILENAME\n";
                if( open( INFILE, "$FILENAME" ) ) {
#  Perform search and replace on input file
                        foreach (<INFILE>) {
                                s/$SEARCH_STRING/$REPLACE_STRING/g;
                                push(@OUT, $_);
                        }
                        close( INFILE );
#  Write updated text back to original file
                        if( open( OUTFILE, "> $FILENAME" ) ) { 
                               foreach (@OUT) {
                                        print OUTFILE "$_"
                               }
                        close( OUTFILE );
                        }
                }
        }
#  If the $FILENAME is a directory read through and send to &replacer
#  Skip "." ".." and symbolic links.
        elsif( -d $FILENAME && -w $FILENAME && !-l $FILENAME ) {
                if( opendir( DIR, "$FILENAME" ) ) {
                        foreach( sort readdir( DIR ) ) {
                                next if( $_ eq "." || $_ eq ".." );
                                &Replacer( $SEARCH, $REPLACE, "$FILENAME/$_" );
                        }
                closedir( DIR );
                }
        }
        else {
                print STDERR "Cannot open $FILENAME: $!\n";
        }
}
exit;