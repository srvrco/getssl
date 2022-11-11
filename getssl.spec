%define _build_id_links none
%define debug_package %{nil}

# set this to true or the rpmbuild will fail with errors due to shebang defines
# in some of the dns scripts for python
%global __brp_mangle_shebangs /usr/bin/true

Summary:          getssl ACME Scripts for managing Let's Encrypt certificates
License:          GPL
Packager:         getssl developers <https://github.com/srvrco/getssl>
Name:             getssl
Version:          2.47
Release:          2

URL:              http://github.com/srvrco/getssl/
Source0:          %{name}-%{version}.tar.gz
Source1:          getssl.crontab
Source2:          getssl.logrotate
BuildArch:        noarch

Requires:         bash cronie
BuildRequires:    bash

%description
The %{name} package contains the getssl scripts, crontab files, and logrotate files for implementing automated creation and installation of SSL certificates from the Let's Encrypt ACME website.

%prep
%setup -q -n %{name}-%{version}

%build

%install
[ -n "%{buildroot}" -a "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}
%{__mkdir_p} %{buildroot}%{_bindir}
%{__mkdir_p} %{buildroot}%{_datadir}/getssl/dns_scripts
%{__mkdir_p} %{buildroot}%{_datadir}/getssl/other_scripts
%{__make} \
	DESTDIR=%{buildroot} \
	install
install -Dpm 644 %{SOURCE1} %{buildroot}%{_sysconfdir}/cron.d/getssl
install -Dpm 644 %{SOURCE2} %{buildroot}%{_sysconfdir}/logrotate.d/getssl

%pre

%post

%preun

%postun

%files
%defattr(-,root,root)
%{_bindir}/getssl
%{_datadir}/getssl/dns_scripts/*
%{_datadir}/getssl/other_scripts/*
%{_sysconfdir}/cron.d/getssl
%{_sysconfdir}/logrotate.d/getssl

%changelog
