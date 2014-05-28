all:

haxelib-release/haxedoc.xml: \
$(wildcard haxelib-release/com/qifun/jsonStream/*.hx) \
$(wildcard haxelib-release/com/qifun/jsonStream/*/*.hx)
	haxe -D doc-gen -xml $@ -cp haxelib-release $(subst /,.,$(patsubst haxelib-release/%.hx,%,$^)) -lib continuation --macro 'exclude("haxe")'

pages: haxelib-release/haxedoc.xml
	haxelib run dox \
	--input-path haxelib-release \
	--output-path $@ \
	--include '^com(\.qifun(\.jsonStream(\..*)?)?)?$$'
	touch $@
