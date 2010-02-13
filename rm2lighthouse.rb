# Redmine to Lighthouse ticket importer
# Author: Jens Krämer <jk@jkraemer.net>
#

# usage:
# place this file into your redmine applicatiojn directory and run via script runner:
#
# RAILS_ENV=production script/runner rm2lighthouse.rb


# Copyright (c) 2010 Jens Krämer
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.


require 'rubygems'
gem 'lighthouse-api'

require 'lighthouse'

############
### Lighthouse configuration
###

# Lighthouse Account Name -- NOT your username!
Lighthouse.account = ''
# Lighthouse API token
Lighthouse.token = ''


# redmine project identifier => lighthouse project id
PROJECTS = {
}

class RmTicketImporter
  
  STATE_MAP = {
    'New' => 'new',
    'Assigned' => 'open',
    'Resolved' => 'resolved',
    'Feedback' => 'open',
    'Closed' => 'resolved',
    'Rejected' => 'invalid'
  }
  
  def initialize(project_mapping)
    @projects = project_mapping
  end
  
  def import
    @projects.each_pair do |rm_proj, lh_proj|
      issues_for_project(rm_proj).each { |issue| create_ticket(issue, lh_proj) }
    end
  end
  
  def issues_for_project(proj)
    Project.find_by_identifier(proj).issues
  end
  
  def create_ticket(rm_issue, proj)
    ticket = Lighthouse::Ticket.new(:project_id => proj)
    ticket.title = rm_issue.subject
    ticket.body = rm_issue.description
    ticket.state = STATE_MAP[rm_issue.status.name]
    # ticket.tags = tag_prep(trac_ticket[:tags] + status_tags)
    # ticket.milestone_id = Config[:milestones][trac_ticket[:milestone]]
    ticket.save
  end
  
end

RmTicketImporter.new(PROJECTS).import
