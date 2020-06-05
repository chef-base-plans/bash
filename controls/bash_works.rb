title 'Tests to confirm bash works as expected'

plan_name = input('plan_name', value: 'binutils')
plan_ident = "#{ENV['HAB_ORIGIN']}/#{plan_name}"
hab_path = input('hab_path', value: 'hab')

control 'core-plans-bash' do
  impact 1.0
  title 'Ensure bash works'
  desc '
  There are two main tests to perform for bash.  We check that the version is correct e.g.

    $ bash --version
    GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin19)
    Copyright (C) 2007 Free Software Foundation, Inc.

  We also check that bash can run commands e.g.

    $ bash -c "echo hello world"
    hello world
  '
  bash_pkg_ident = command("#{hab_path} pkg path #{plan_ident}")
  describe bash_pkg_ident do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end
  bash_pkg_ident = bash_pkg_ident.stdout.strip

  describe command("#{bash_pkg_ident}/bin/bash --version") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /GNU bash, version\s+#{bash_pkg_ident.split('/')[5]}/ }
    its('stderr') { should be_empty }
  end

  describe command("#{bash_pkg_ident}/bin/bash -c 'echo $BASH'") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should eq "#{bash_pkg_ident}/bin/bash\n" }
    its('stderr') { should be_empty }
  end
end