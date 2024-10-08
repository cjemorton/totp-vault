#!/usr/pkg/bin/bash
# This project is intended to quickly bootstrap an environment where TOTO keys can be used.
##
# Check to make sure curl is installed
if ! curl --version &> /dev/null; then
        echo "Please install curl"
        exit 1
fi

#-------------------------------------------------------------#
# Check python3 version.
if ! python --version &> /dev/null; then
    echo "Python3 is not installed."
    exit 1
fi

# Extract the major version number
version=$(python --version | awk '{print $2}' | cut -d. -f1)

if [[ "$version" -lt 3 ]]; then
    echo "Python3 is installed, but the version is less than 3."
    exit 1
fi

# Check to see if gpg is installed.
if ! gpg --version &> /dev/null; then
	echo "gpg is not installed."
	exit 1
fi
version=$(gpg --version | head -n 1 | awk '{print $3}' | cut -d. -f 1)
if [[ "$version" -lt 1 ]]; then
    echo "gpg is installed but it's version is less than 1.0.0"
    exit 1
fi

# # Check to see if 'pip' is installed"
if ! pip --version &> /dev/null; then
	export PATH=$HOME/.local/bin:$PATH
		if ! pip --version &> /dev/null; then
			echo "'pip' is not installed, go get and install it"
			curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
			python get-pip.py --user
			export PATH=$HOME/.local/bin:$PATH
			# Check if get-pip.py exists and remove it.
			[ -f "get-pip.py" ] && rm get-pip.py
		fi
fi
version=$(pip --version | awk '{print $2}' | cut -d. -f 1)
if [[ "$version" -lt 1 ]]; then
    echo "'pip' is installed but it's version is less than 1."
	pip --version | awk '{print $2}'
    exit 1
fi
# Check to see if required packages for totp_generator.py in pip are installed.
if ! python -c "import pyotp" &> /dev/null; then
    echo "pyotp is not installed. Installing pyotp..."
    pip install pyotp --user
fi
# Check to see if git is installed.
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git to proceed."
    exit 1
fi
# Check to see if the git repository is installed with the required totp_generator.py pulled down.
if [ ! -d "totp_generator.py" ]; then
    echo "Folder 'totp_generator.py' does not exist. Cloning repository..."
    git clone https://github.com/cjemorton/totp_generator.py.git
fi

# Check to see if a gpg file containing the totp key is located.

echo "-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --"
if ls *.gpg 1> /dev/null 2>&1; then
	python totp_generator.py/totp_generator.py $(gpg -d --quiet --no-verbose *.gpg 2>&1 | grep -v '^gpg: ')
else
###-----------
		# Check if an argument is provided
		if [ "$#" -eq 0 ]; then
		    echo "No URL provided."
		    exit 1
		fi
		url="$1"
		# Basic URL validation
		if [[ ! "$url" =~ ^https?:// ]]; then
		    echo "Invalid URL: URL must start with http:// or https://"
		    exit 1
		fi
		# Check if the URL is reachable
		if ! curl --head --silent --fail "$url" > /dev/null; then
		    echo "Invalid URL: The URL is not reachable."
		    exit 1
		fi
		json_data=$(curl -s $url)
		TOTP=$(echo $json_data | jq -r . | base64 -D)
		python totp_generator.py/totp_generator.py $(echo "$TOTP" | gpg -d --no-verbose --quiet 2>&1 | grep -v '^gpg: ')

		echo "$TOTP" > key.txt.gpg
fi
echo "-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --"
