Name:		monitoring-plugins-sfl-check-ceilometer
Version:    	0.3.2
Release:    	1
License: 	GPL v3
Summary: 	Shinken plugin from SFL. A Nagios plug-in to use OpenStack Ceilometer API for metering
Group: 		Networking/Other
Source0: 	https://github.com/savoirfairelinux/monitoring-tools/%{name}_%{version}.orig.tar.gz
URL:            https://github.com/savoirfairelinux/monitoring-tools
Packager: Alexandre Viau <alexandre.viau@savoirfairelinux.com>

BuildRequires:  python-setuptools

Requires: python-ceilometerclient

BuildArch: noarch

%description 
Shinken plugin from SFL. A Nagios plug-in to use OpenStack Ceilometer API for metering

%prep
%setup -q -n check_ceilometer

%build
%{__python} setup.py build

%install
%{__python} setup.py install -O1 --skip-build --root %{buildroot}

# Remove useless files
rm -rf  %{buildroot}/%{python_sitelib}/shinkenplugins.plugins.ceilometer*.egg-info*
rm %{buildroot}/%{python_sitelib}/shinkenplugins.plugins.ceilometer-1.2-py2.7-nspkg.pth


%files
%{python_sitelib}/shinkenplugins/plugins/ceilometer/*
%{_bindir}/check_ceilometer


%changelog
* Fri Jun 12 2015 Flavien Peyre <flavien.peyre@savoirfairelinux.com>
- Updated to 0.3.2

* Mon May 05 2014 Alexandre Viau <alexandre.viau@savoirfairelinux.com>
- Initial Release
