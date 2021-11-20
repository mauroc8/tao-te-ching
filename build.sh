rm -rf docs
mkdir docs
LANGUAGE="English StephenMitchell" npx parcel build src/index.html --public-url ./ --out-dir docs/
LANGUAGE="English AddissAndLombardo" npx parcel build src/index.html --public-url ./ --out-dir docs/addiss-lombardo/
LANGUAGE="Spanish" npx parcel build src/index.html --public-url ./ --out-dir docs/es/
