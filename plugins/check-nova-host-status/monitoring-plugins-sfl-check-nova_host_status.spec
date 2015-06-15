Name:           monitoring-plugins-sfl-check-nova-host-status
Version:        0.3.2
Release:        1
Summary:        Check the current status for a nova host

License:        GPLv3
URL:            https://github.com/savoirfairelinux/monitoring-tools
Source0:        https://github.com/savoirfairelinux/monitoring-tools/%{name}_%{version}.orig.tar.gz

BuildRequires:  python-setuptools

Requires:       python-shinkenplugins
Requires:       python-novaclient

BuildArch:      noarch

%description
check the current status for a nova host
More information is available on Github:
https://github.com/savoirfairelinux/sfl-monitoring-tools

%prep
%setup -q -n check_nova_host_status


%build
%{__python} setup.py build


%install
%{__python} setup.py install -O1 --skip-build --root %{buildroot}

# Remove useless files
rm -rf  %{buildroot}/%{python_sitelib}/shinkenplugins.plugins.nova_host_status*.egg-info*
rm %{buildroot}/%{python_sitelib}/shinkenplugins.plugins.nova_host_status-1.0-py2.7-nspkg.pth

%files
%{python_sitelib}/shinkenplugins/plugins/nova_host_status/*
%{_bindir}/check_nova_host_status


%changelog
* Mon Jun 15 2015 Vincent Fournier <vincent.fournier@savoirfairelinux.com> - 0.3.2-1
- Updated to 0.3.2

* Fri May 29 2015 Flavien Peyre <peyre.flavien@gmail.com> - 2015.5.29.13.21
- Initial package
