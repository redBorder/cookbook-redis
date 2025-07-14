Name: cookbook-redis
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-redis
Source0: %{name}-%{version}.tar.gz

Requires: dos2unix

Summary: redis cookbook to install and configure it in redborder environments
%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/redis
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/redis/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/redis
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/redis/README.md

%pre

%post
/usr/lib/redborder/bin/rb_rubywrapper.sh -c
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload redis'
  ;;
esac

%files
%defattr(0755,root,root)
/var/chef/cookbooks/redis
%defattr(0644,root,root)
/var/chef/cookbooks/redis/README.md

%doc

%changelog
* Mon Jul 14 2025 Rafael Gómez <rgomez@redborder.com> - 
- First version