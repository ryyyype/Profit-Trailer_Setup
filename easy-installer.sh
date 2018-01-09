#!/bin/bash

# Set variables
# -----------------------------------
PT_FOLDER_NAME="pt"
CODENAME=$(lsb_release -c | awk '$1=="Codename:"{print $2}')

# Set functions
# -----------------------------------
logMessage () {
  echo " $1"
  echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}


echo ""
echo " ============================================================"
echo "                    Profit-Trailer SETUP started"
echo ""
echo "                    This will take a few seconds"
echo ""
echo " ============================================================"
echo ""

logMessage "(1/1) Update the base system"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
apt-get -qq update > /dev/null 2>&1
apt-get -qq upgrade > /dev/null 2>&1

logMessage "(2/2) Install dependency tools for Profit-Trailer"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
apt-get -y -qq purge openjdk* > /dev/null 2>&1
apt-get -y -qq purge java7* > /dev/null 2>&1
apt-get -y -qq autoremove > /dev/null 2>&1
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 > /dev/null 2>&1
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu $CODENAME main" >> /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu $CODENAME main" >> /etc/apt/sources.list
apt-get -qq update > /dev/null 2>&1
apt-get -y -qq install oracle-java8-installer > /dev/null 2>&1
apt-get -y -qq install oracle-java8-set-default > /dev/null 2>&1

logMessage "(3/3) Install tools"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
apt-get -y -qq install build-essential > /dev/null 2>&1
apt-get -y -qq install curl > /dev/null 2>&1
apt-get -y -qq install jq > /dev/null 2>&1
apt-get -y -qq install unzip > /dev/null 2>&1
curl -qsL https://deb.nodesource.com/setup_6.x | bash - > /dev/null 2>&1
apt-get -y -qq install nodejs > /dev/null 2>&1
ln -s /usr/bin/nodejs /usr/bin/node > /dev/null 2>&1
apt-get -y -qq install npm > /dev/null 2>&1
npm install pm2@latest -g > /dev/null 2>&1

# Set variables
# -----------------------------------
PT_GITHUB_LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases/latest 2>/dev/null | awk -F'"' '$2=="browser_download_url"{print $4}')
PT_GITHUB_LATEST_RELEASE_TAG_NAME=$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases/latest 2>/dev/null | awk -F'"' '$2=="tag_name"{print $4}')
PT_GITHUB_LATEST_RELEASE_PUBLISHED=$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases/latest 2>/dev/null | awk -F'"' '$2=="published_at"{print $4}')
PT_GITHUB_LATEST_RELEASE_NAME=$(curl -s https://api.github.com/repos/taniman/profit-trailer/releases/latest 2>/dev/null | jq -r ".assets" | awk -F'"' '$2=="name"{print $4}')

logMessage "(4/4) Install Profit-Trailer"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo " Get latest release of Profit-Trailer"
echo " Latest release: $PT_GITHUB_LATEST_RELEASE_TAG_NAME"
echo " Published at: $PT_GITHUB_LATEST_RELEASE_PUBLISHED"
wget -q $PT_GITHUB_LATEST_RELEASE_URL -P /opt/
unzip -o -qq /opt/${PT_GITHUB_LATEST_RELEASE_NAME::-4}.zip -d /opt/unzip-tmp

# create folder for the current version.
mkdir /opt/${PT_FOLDER_NAME} -p

# Copy
cp -f -r /opt/unzip-tmp/ProfitTrailer/* /opt/${PT_FOLDER_NAME}

# Cleanup
rm /opt/${PT_GITHUB_LATEST_RELEASE_NAME::-4}.zip
rm -R /opt/unzip-tmp

# Set rights
chmod +x /opt/$PT_FOLDER_NAME/ProfitTrailer.jar




echo ""
echo " ============================================================"
echo "                   Profit-Trailer SETUP complete!"
echo ""
echo " ============================================================"
echo ""
