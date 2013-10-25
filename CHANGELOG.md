## 1.0.0

## 0.4.0

### Enhancements
- Added index page functionality for source types and documentations.
- Created Tags for Subjects to enable grouping of subjects.
- Added from_s functionality to Labtime
- Created rough version of subject show page, with space for raster plots.

### ETL
- Updated actigraphy loader and merger, allowing for actigraphy data to be loaded.
- Enabled loading of melatonin and cbt phase information for fd subjects
- Created DBF reader to remove "deleted" flags from DBF files and mirror Roo access to them
- Added DBF functionality to DatabaseLoader
- Created TDriveCrawler to find files on the T drive that fit a given file pattern and set them up for loading.
- Added functionality for skipping rows depending on conditions to DatabaseLoader
- Database Loader can now deal with a much wider range of realtime and labtime input formats.
- Created DBF loader.
- Loaded New Forms for authorized subjects

### Bug Fix
- Data Dictionary form fixed to work with sub-uris.

## 0.3.0

### Enhancements
- Upgraded to ruby 2.0
- Upgraded to markdown documentation
- Using .ruby-version file instead of .rvmrc file
- Refreshed navigation bar organization to remove clutter, improve clarity, and highlight important pages
- Added index page functionality (sorting, pagination, etc.) for subjects, data dictionary, and event dictionary
- Added gravatar support
- Improved show pages for subjects and dictionaries.

### ETL
- Updated subject information and subject demographics loaders
- Updated actigraphy merger
- Loaded Light Intervention and FD Subject Demographics
- Merged FD actigraphy files

### Bug Fix
- Fixed load problems for subject information and database loader
- Fixed many problems with Data Dictionary creation and update (allowed values, values not showing, duplicate entries)
