# Release: v0.013+L6.L7

## Deployment Quickstart

1. **Extract Release**: Unpack the release archive to your deployment target
2. **Review Versions**: Check VERSION.txt and layer version information below
3. **Run Configuration**: Execute the included build configuration
4. **Verify Installation**: Test each layer's functionality

## Layer Version Summary

| Layer | Name | Version |
|-------|------|---------|
| L1 | Physical | 0.0.6 |
| L2 | Runtime | 0.0.4 |
| L3 | Channel | 0.0.4 |
| L4 | Session | 0.0.4 |
| L5 | Routing | 0.0.4 |
| L6 | Processing | 0.0.4 |
| L7 | Memory | 0.0.4 |

## File Manifest

```
releases/VERSION_TAG/
├── CHANGELOG.md          # Detailed change log
├── README.md            # This file
├── VERSION.txt          # Version tag reference
├── openclaw.json        # Configuration
├── LAYERS-MANIFEST.json # Layer metadata
└── context-files/       # Context and support files
    └── ...
```

## Setup Instructions

1. Review CHANGELOG.md for changes and migration notes
2. Compare VERSION.txt with your current version
3. Deploy using your normal release procedure
4. Verify all layers are functioning correctly

## Support

For issues or questions, refer to the project documentation.
