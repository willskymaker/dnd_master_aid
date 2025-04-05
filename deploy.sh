#!/bin/bash

set -e

echo "🛠️  Build del progetto Web..."
flutter build web

echo "🚀 Deploy su GitHub Pages..."
git worktree add /tmp/gh-pages gh-pages
rm -rf /tmp/gh-pages/*
cp -r build/web/* /tmp/gh-pages/

cd /tmp/gh-pages
git add .
git commit -m "Deploy aggiornato"
git push origin gh-pages

echo "✅ Deploy completato su GitHub Pages!"
