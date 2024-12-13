# TileServer GL Styles

## Build Sprites

```shell
cargo install spreet

mkdir -p ./tmp
cp -a ./data/svgs/osm-liberty/svgs_not_in_iconset/. ./tmp/ 
cp -a ./data/svgs/osm-liberty/svgs_iconset/. ./tmp/ 
spreet ./tmp/ ./data/sprites/osm-liberty/sprite
spreet --retina ./tmp/ ./data/sprites/osm-liberty/sprite@2x 
rm -r ./tmp
```

## Reference

- https://github.com/openmaptiles/spreet
- https://github.com/openmaptiles/osm-liberty-gl-style
- https://github.com/orangemug/font-glyphs
- https://github.com/orangemug/font-glyphs-v2