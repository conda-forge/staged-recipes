{
  # Run Run BeakerX uninstall script
  "${PREFIX}/bin/beakerx-install" --disable
  # Uninstall BeakerX notebook extension
  "${PREFIX}/bin/jupyter-nbextension" uninstall beakerx --py --sys-prefix
  # TODO: Restore original custom CSS and assets to notebook custom directory
} >> "${PREFIX}/.messages.txt" 2>&1
