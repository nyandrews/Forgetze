#!/bin/bash

ASSETS_DIR="/Users/markandrews/Documents/ForgetzeClone/Forgetze/Forgetze/Assets.xcassets"
SOURCE_DIR="/Users/markandrews/Documents/ForgetzeClone/Forgetze/Docs/Images"

# Function to create imageset
create_imageset() {
    local asset_name=$1
    local filename=$2
    local imageset_dir="$ASSETS_DIR/$asset_name.imageset"
    
    echo "Creating $imageset_dir"
    mkdir -p "$imageset_dir"
    
    cp "$SOURCE_DIR/$filename" "$imageset_dir/$filename"
    
    cat > "$imageset_dir/Contents.json" <<EOF
{
  "images" : [
    {
      "filename" : "$filename",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
}

create_imageset "forgetze_home_screen" "forgetze_home_screen.png"
create_imageset "forgetze_contact_detail" "forgetze_contact_detail.png"
create_imageset "forgetze_edit_contact" "forgetze_edit_contact.png"
create_imageset "forgetze_data_protection" "forgetze_data_protection.png"

echo "Assets imported successfully."
