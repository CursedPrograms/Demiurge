// Demiurge's page: the feature cards and the year
(function () {
  'use strict';
  const features = [
    ['2D and 3D', 'Pixel-perfect 2D with tilemaps and its own renderer, and 3D with real-time global illumination, volumetric fog and screen-space effects.'],
    ['Scenes all the way down', 'Everything is a tree of nodes: build a player, a door or a whole level as a scene and drop it into other scenes.'],
    ['Write it your way', 'GDScript, built for games and easy to learn, or C# (.NET 8), a visual shader editor, and C++ through GDExtension for the heavy parts.'],
    ['Physics and animation', 'Bodies, joints and ragdolls in 2D and 3D, an animation player for anything, blend trees and state machines for characters.'],
    ['One click to play', 'Export to Windows and Linux from the editor; Demiurge\'s own export templates come with it.'],
    ['The Atelier look', 'The Changeling greys and the Atelier blue, square and flat, laid out like Unity: Scene on the left, Inspector on the right, FileSystem along the bottom. Projects in the project.godot format work as they are.']
  ];
  const grid = document.getElementById('features');
  if (grid) {
    for (const [title, text] of features) {
      const card = document.createElement('article');
      const h = document.createElement('h2');
      h.textContent = title;
      const p = document.createElement('p');
      p.textContent = text;
      card.append(h, p);
      grid.appendChild(card);
    }
  }
  const year = document.getElementById('year');
  if (year) year.textContent = String(Math.max(2026, new Date().getFullYear()));
})();
