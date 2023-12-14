import os
import re
import sys

workdir = sys.argv[1]
files = [s for s in os.listdir(workdir) if any(c.isdigit() for c in s) and s.split(".")[-1] == "jar" ]

namecollection = {}
for file in files:
  allname = os.path.splitext(os.path.basename(file))[0]
  version = allname.split("-")[-1]
  purename = "-".join(allname.split("-")[0:-1])
  if purename not in namecollection:
    namecollection[purename] = [version]
  else:
    namecollection[purename].append(version)

for purename in namecollection:
  namecollection[purename] = sorted(namecollection[purename], key=lambda v: [int(n) if n.isdigit() else n for n in re.split(r'(\d+)', v)], reverse=True)
  namecollection[purename].pop(0)

cleanednames = {x:namecollection[x] for x in namecollection if len(namecollection[x]) > 0}

removelist = []
for cname in cleanednames:
  for cversion in cleanednames[cname]:
    removelist.append(f"{'-'.join([cname,cversion])}.jar" )
print(f"removing {removelist}")

for filename in removelist:
  os.remove(os.path.join(workdir,filename))