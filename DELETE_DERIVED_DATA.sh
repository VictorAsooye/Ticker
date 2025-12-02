#!/bin/bash

# Script to delete Xcode DerivedData for TickerCodebase
# This fixes "No such module" errors when packages are correctly linked

echo "🗑️  Deleting Xcode DerivedData for TickerCodebase..."
echo ""

# Find and delete DerivedData folder
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData/TickerCodebase-*"

if ls $DERIVED_DATA_PATH 1> /dev/null 2>&1; then
    echo "Found DerivedData folder, deleting..."
    rm -rf $DERIVED_DATA_PATH
    echo "✅ Deleted DerivedData"
else
    echo "⚠️  No DerivedData folder found (might already be deleted)"
fi

echo ""
echo "📝 Next steps:"
echo "1. Close Xcode completely (Cmd+Q)"
echo "2. Reopen Xcode"
echo "3. Open TickerCodebase.xcodeproj"
echo "4. Wait for indexing to finish (check top right)"
echo "5. Clean Build Folder (Shift+Cmd+K)"
echo "6. Build (Cmd+B)"
echo ""
echo "✅ This should fix the 'No such module FirebaseCore' error!"


