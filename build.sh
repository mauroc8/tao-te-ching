rm -rf build
mkdir build
LANGUAGE="English StephenMitchell" parcel build src/index.html --public-url ./ --out-dir build/
LANGUAGE="English AddissAndLombardo" parcel build src/index.html --public-url ./ --out-dir build/addiss-lombardo/
LANGUAGE="Spanish" parcel build src/index.html --public-url ./ --out-dir build/es/
