## Using INWX DNS for LetsEncrypt domain validation

### Install Requirements

The INWX API Python3 script requires two Python packages:

```bash
pip3 install INWX.Domrobot tldextract
```

You could install it for the user running getssl, or you could create a python3 venv.

```bash
# install python3 venv apt packages
sudo apt install python3 python3-venv

# Create venv
python3 -m venv venv

# activate venv
source venv/bin/activate

# install requirements
pip3 install INWX.Domrobot tldextract
```

If you are installing the Python packages in venv, you should make sure that you either
you either enable the venv before running getssl, or you
add the venv to the ``DNS_ADD_COMMAND'' and ``DNS_DEL_COMMAND'' commands.
See example below.

### Enabling the scripts

Set the following options in `getssl.cfg` (either global or domain-specific):

```
VALIDATE_VIA_DNS="true"
DNS_ADD_COMMAND="/usr/share/getssl/dns_scripts/dns_add_inwx.py"
DNS_DEL_COMMAND="/usr/share/getssl/dns_scripts/dns_del_inwx.py"
```

If you are using a python3 venv as described above, this is an example of how to include it:

```
VALIDATE_VIA_DNS="true"
DNS_ADD_COMMAND="/path/to/venv/bin/python3 /usr/share/getssl/dns_scripts/dns_add_inwx.py"
DNS_DEL_COMMAND="/path/to/venv/bin/python3 /usr/share/getssl/dns_scripts/dns_del_inwx.py"
```

*Obviously the "/path/to/venv" needs to be replaced with the actual path to your venv, e.g. "/home/getssl/venv".*

### Authentication

Your INWX credentials will be used to authenticate to INWX.
If you are using a second factor, please have a look at the [INWX Domrobot Pthon3 Client](https://github.com/inwx/python-client) as it is currently not implemented in the inwx api script.

Set the following options in the domain-specific `getssl.cfg` or make sure these enviroment variables are present.

```
export INWX_USERNAME="your_inwx_username"
export INWX_PASSWORD="..."
```
