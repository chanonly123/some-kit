echo "Enter tag: "
read fullname
git add . &&
git commit -m "updates" &&
git tag "$fullname" &&
git push --tags &&
git push

