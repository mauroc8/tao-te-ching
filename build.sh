rm -rf docs
mkdir docs
LANGUAGE="English StephenMitchell" parcel build src/index.html --public-url ./ --out-dir docs/
LANGUAGE="English AddissAndLombardo" parcel build src/index.html --public-url ./ --out-dir docs/addiss-lombardo/
LANGUAGE="Spanish" parcel build src/index.html --public-url ./ --out-dir docs/es/
