#!/bin/bash

# CyberChef
echo -e "Installing CyberChef locally"
CYBERCHEFDIR="${HOME}/.local/share/cyberchef"
CYBERCHEFBIN="${HOME}/.local/bin"

mkdir -p "$CYBERCHEFDIR"
mkdir -p "$CYBERCHEFBIN"

cp CyberChef*.zip "${CYBERCHEFDIR}/."
cd "$CYBERCHEFDIR"

unzip -qq *.zip

echo -e "#!/bin/bash\n\nxdg-open ${CYBERCHEFDIR}/*.html" > "${CYBERCHEFBIN}/cyberchef"
chmod +x "${CYBERCHEFBIN}/cyberchef"

cd - >/dev/null
ln -s "${CYBERCHEFBIN}/cyberchef" cyberchef
chmod +x cyberchef
echo "See 'cyberchef' executable in cwd"