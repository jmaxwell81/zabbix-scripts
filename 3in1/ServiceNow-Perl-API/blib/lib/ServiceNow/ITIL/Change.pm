# ======================================================================
#
#   Copyright 2010 davidloo Service-now.com
#   Copyright 2015 Daniel Hernández Cassel
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# ======================================================================

package ServiceNow::ITIL::Change;
use ServiceNow::GlideRecord;
use ServiceNow::ITIL::Task;

$VERSION = '1.00';
@ISA = (ServiceNow::ITIL::Task);

=pod

=head1 Change module

Service-now Perl API - Change perl module

=head1 Desciption

An object representation of an Change in the Service-now platform.  Provides subroutines for querying, updating, and creating change requests. 

=head2 System Requirements

The Service-now Perl API requires Perl 5.8 with the following modules installed

  * SOAP::Lite (prerequisites http://soaplite.com/prereqs.html) 0.71 or later
  * Crypt::SSLeay
  * IO::Socket::SSL

=head1 Constructor

=head2 new

new(Configuration);

Example:

  $change = ServiceNow::ITIL::Change->new($CONFIG);

Takes a configuration object and manufactures an Change object connected to the Service-now instance

=cut

sub new {
  my $class = shift; 
  my $config = shift;
  my $me = {};
  
  bless($me,$class);
  ServiceNow::GlideRecord->new($config, "change_request", $me);
  return $me;
}

1;