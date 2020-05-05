
Export Profile Plus
===================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0) ![This script was last tested in Nuix 8.4](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-8.4-green.svg)

View the [GitHub project here](https://github.com/Nuix/Export-Profile-Plus) or [download the latest release here](https://github.com/Nuix/Export-Profile-Plus/releases).

# Overview

**Written By:** Jason Wells

This script allows you to export a base metadata profile along with optional calculated fields for a selection of items.

 **Note:** It is highly recommended you run this script in a session of Nuix which you have started using the argument `-Dfile.encoding=utf8` to help ensure that any Unicode characters which may be present in exported data are not mangled during export!

# Getting Started

## Setup

Begin by downloading the latest release.  Extract the the directory `ExportProfilePlus.nuixscript' and its contents from the archive into your Nuix scripts directory.  In Windows this directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Usage

Before running the script you will need to have a case open in Nuix and a selection of items which you wish to work with.

### Profile Fields Tab

On this tab you configure what fields are used.

- **Build Upon Base Profile**: When checked the script will extend the base metadata profile you select to include the "Additional Fields".  When un-checked the script will create a new temporary metadata profile containing only the selected "Additional Fields".  When this option is un-checked you are required to select at least one "Additional Field".  **Note**: The base profile is only temporarily extended in memory by the script, the metadata profile will not be modified permanently.
- **Base Profile**: This is the metadata profile which will be used as the basis for the export/annotation operation being performed.
- **Additional Fields**: This is where you may specify any additional fields the script is able to calculate which will be included with the base profile for the export/annotation operation being performed.  See [Additional Fields](#additional-fields) below for more details.

Additionally there are settings:

- **Do not report on excluded items**: Removes excluded items from reporting, including instances where a given field's calculation may pull them in.
- **Multi-value Field Delimiter**: The delimiter used when a given single field may contain delimited values.  The default is `; ` (semicolon space).

### Load Files Tab

On this tab you are able to specify one or more output file formats.

- **Export CSV**: Whether you would like to export a CSV
	- **CSV File**: The location to which you would like to export the CSV file.
- **Export DAT**: Whether you would like to export a DAT file
	- **DAT File**: The location to which you would like to export the DAT file.
- **Export TSV**: Whether you would like to export a TSV file
	- **TSV File**: The location to which you would like to export the TSV file.
- **Export XLSX**: Whether you would like to export an Excel XLSX file
	- **XLSX File**: The location to which you would like to export the XLSX file.
- **Export custom format**: Whether to export a customized delimited file format.
	- **Custom File**: The location to which you would like to export your custom file to.
	- **Custom Delimiter**: The delimiter string to use
	- **Custom Quote**: The field quoting string to use.  Can be blank if not needed.

**Note**:  Excel imposes a 32K character limit per cell.  To prevent errors while exporting data to XLSX format, values longer than 32K characters are truncated down to 32K characters.


### Custom Metadata Tab

- **Apply as Custom Metadata**: When checked each selected item will have all specified fields applied as custom metadata fields.

### Apply as Single Concatenated Custom Metadata Field Tab

On this tab you are able to provide settings for applying a single custom metadata field with the specified fields concatenated as a single value.

- **Apply as Single Custom Metadata Field**:  When checked each selected item will have a custom metdata field applied where the value is a concatenation of the profile values, separated by `; `.
	- **Field Name**: The name of the custom metdata field.
	- **Include Field Names**: Whether the field names are included with each value in the custom metdata field value.  
For example, without field names the value might be   
``c758ba3c-3628-4c0a-9101-cf03422e81c6; Data2; ; ; false; 0``  
and with field names the value would be  
``GUID: c758ba3c-3628-4c0a-9101-cf03422e81c6; Name: Data2; FailureDetail: ; FailureMessage: ; Audited: false; Audited Size: 0``.
	- **Exclude Null or Empty Values**: When checked, if a given field for a given item has a value of `null` or only whitespace, that field (and field name) will not be included in the custom metdata value for that item.

### Item Sets Tab

On this tab you may specify one or more item sets which will be used by scripted fields which perform their calculation based on selected item sets.  Note that item sets created using a scripted expression will not be listed.  This is because calls to [ItemSet.findDuplicates](https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/ItemSet.html#findDuplicates-nuix.Item-) will throw errors when the given item set was created using a scripted expression.

## Scripted Additional Fields

These fields values are determined by code in this script rather than metadata profile fields built into Nuix.

### Domains Fields

Domains fields generate listings of domains found in particular fields.  Domains are parsed from [Address] objects using the following regular expression:

```
^[^@]+@(.*)$
```

The domain being the value of the first and only capture group.  This will yield a blank value for items which do not have an associated [Communication] object.  See API documentation for [Item.getCommunication]

- **All Domains**
	- From
	- To
	- CC
	- BCC
- **Recipients Domains**
	- To
	- CC
	- BCC
- **From Domains**
	- From
- **To Domains**
	- To
- **CC Domains**
	- CC
- **BCC Domains**
	- BCC

### Recipient Count

Exports a field containing the number of recipient (To, CC and BCC) addresses associated with a given item (if any).

### To Recipient Count

Exports a field containing the number of recipient addresses in the TO field for a given item.

### CC Recipient Count

Exports a field containing the number of recipient addresses in the CC field for a given item.

### BCC Recipient Count

Exports a field containing the number of recipient addresses in the BCC field for a given item.

### Binary Available

Exports a field containing `true` or `false` depending on whether Nuix is able to access the binary data of a given item.

Internally this works by calling [Item.getBinary] which returns a [Binary] object.  Then using this object, [Binary.getBinaryData] is called which returns a [BinaryData] object.  Using this object [BinaryData.getLength] is called.  This method will either succeed if Nuix can reach the object's binary or fail.  Depending on whether or not this call fails is then used to determine whether a value of `true` or `false` is yielded for a given item.

### Stored Binary Path

Returns a path to the file system where the binary for a given item is stored if the file system stored binary was used while ingesting a given item.

Internally this works by calling [Item.getBinary] which returns a [Binary] object.  Then using this object, [Binary.getStoredPath] is called which either returns the file system bath to the binary or `null`.  When the value is `null` the report will contain a blank value.

### Stored Text Path

Returns a path to the file system where the text for a given item is stored if the file system stored text setting was used while ingesting a given item.

Internally this works by calling [Item.getTextObject] which returns a [Text] object.  Using this object [Text.getStoredPath] is called.  If this call returns `null`, then a blank value is reported for the item.

### Digest Lists

This field reports a delimited list of digest lists that a given item's MD5 is a member of.

Internally this accomplished by searching upfront for all the items in each digest list.  Then when calculating the value for a given item, the item is intersected (using a call to [ItemUtility.intersection]) against each digest list's reference set of items to see if the item is present in the given digest list.

### Irregular Category

This field will contain a delimited list of all the irregular items categories a given item is a member of.

Internally this accomplished by searching upfront for all the items in each irregular category.  Then when calculating the value for a given item, the item is intersected (using a call to [ItemUtility.intersection]) against each category's reference set of items to see if the item is present in the given category.

<table class="table table-bordered">
<tr><th>Category Name </th><th>Query </th></tr>
<tr><td>Corrupted Container</td><td><code>properties:FailureDetail AND encrypted:0 AND has-text:0 AND ( has-embedded-data:1 OR kind:container OR kind:database )</code> </td></tr>
<tr><td>Unsupported Container</td><td><code>kind:( container OR database ) AND encrypted:0 AND has-embedded-data:0 AND NOT flag:partially_processed AND NOT flag:not_processed AND NOT properties:FailureDetail</code> </td></tr>
<tr><td>Non-searchable PDFs</td><td><code>mime-type:application/pdf AND contains-text:0</code> </td></tr>
<tr><td>Text Updated</td><td><code>previous-version-docid:*</code> </td></tr>
<tr><td>Bad Extension</td><td><code>flag:irregular_file_extension</code> </td></tr>
<tr><td>Unrecognised</td><td><code>kind:unrecognised</code> </td></tr>
<tr><td>Unsupported Items</td><td><code>encrypted:0 AND has-embedded-data:0 AND ( ( has-text:0 AND has-image:0 AND NOT flag:not_processed AND NOT kind:multimedia AND NOT mime-type:application/vnd.ms-shortcut AND NOT mime-type:application/x-contact AND NOT kind:system AND NOT mime-type:( application/vnd.logstash-log-entry OR application/vnd.ms-iis-log-entry OR application/vnd.ms-windows-event-log-record OR application/vnd.ms-windows-event-logx-record OR application/vnd.tcpdump.record OR filesystem/x-ntfs-logfile-record OR server/dropbox-log-event OR text/x-common-log-entry OR text/x-log-entry ) AND NOT mime-type:( application/vnd.logstash-log OR application/vnd.logstash-log-entry OR application/vnd.ms-iis-log OR application/vnd.ms-iis-log-entry OR application/vnd.ms-windows-event-log OR application/vnd.ms-windows-event-log-record OR application/vnd.ms-windows-event-logx OR application/vnd.ms-windows-event-logx-chunk OR application/vnd.ms-windows-event-logx-record OR application/vnd.tcpdump.pcap OR application/vnd.tcpdump.record OR application/x-pcapng OR server/dropbox-log OR server/dropbox-log-event OR text/x-common-log OR text/x-common-log-entry OR text/x-log-entry OR text/x-nuix-log ) AND NOT mime-type:application/vnd.ms-exchange-stm ) OR mime-type:application/vnd.lotus-notes )</code> </td></tr>
<tr><td>Empty</td><td><code>mime-type:application/x-empty</code> </td></tr>
<tr><td>Encrypted</td><td><code>encrypted:1</code> </td></tr>
<tr><td>Decrypted</td><td><code>flag:decrypted</code> </td></tr>
<tr><td>Deleted</td><td><code>deleted:1</code> </td></tr>
<tr><td>Corrupted</td><td><code>properties:FailureDetail AND NOT encrypted:1</code> </td></tr>
<tr><td>Text Stripped</td><td><code>flag:text_stripped</code> </td></tr>
<tr><td>Text Not Indexed</td><td><code>flag:text_not_indexed</code> </td></tr>
<tr><td>Licence Restricted</td><td><code>flag:licence_restricted</code> </td></tr>
<tr><td>Not Processed</td><td><code>flag:not_processed</code> </td></tr>
<tr><td>Partially Processed</td><td><code>flag:partially_processed</code> </td></tr>
<tr><td>Text Not Processed</td><td><code>flag:text_not_processed</code> </td></tr>
<tr><td>Images Not Processed</td><td><code>flag:images_not_processed</code> </td></tr>
<tr><td>Reloaded</td><td><code>flag:reloaded</code> </td></tr>
<tr><td>Poisoned</td><td><code>flag:poison</code> </td></tr>
<tr><td>Slack Space</td><td><code>flag:slack_space</code> </td></tr>
<tr><td>Unallocated Space</td><td><code>flag:unallocated_space</code> </td></tr>
<tr><td>Carved</td><td><code>flag:carved</code> </td></tr>
<tr><td>Deleted - All Blocks Available</td><td><code>flag:fully_recovered</code> </td></tr>
<tr><td>Deleted - Some Blocks Available</td><td><code>flag:partially_recovered</code> </td></tr>
<tr><td>Deleted - Metadata Recovered</td><td><code>flag:metadata_recovered</code> </td></tr>
<tr><td>Hidden Stream</td><td><code>flag:hidden_stream</code> </td></tr>
</table>

### Item Text

This field will contain the content text of a item.

**Note:** Care should be taken when using this field.  Due to the potentially large amount of text an item can contain this can cause issues.  As noted in the API documentation for [Text.toString]

> Because this reads the entire text of the item into a single string, memory may run out for items with too much text to fit in memory.

### Item Family Text

This field will contain the content text of all items in the same family as the item (including the given item) in item position order.  If an item is above top level then this will be the same value as **Item Text**.

**Note:** As with the field **Item Text**, care should be taken when using this field.  Due to the potentially large amount of text an item can contain this can cause issues.  As noted in the API documentation for [Text.toString]

> Because this reads the entire text of the item into a single string, memory may run out for items with too much text to fit in memory.

### Property Names

This field will yield a value containing a delimited list of all the property names for a given item.

### Duplicate Path Directories

This field yields a value similar to `Duplicate Paths`, except that the file name (last path segment) is removed from each path so that each value is just the directory portion of the duplicate path.  This is done using the following logic:

1. Get Nuix value for `Duplicate Paths`
1. Split value into multiple values by splitting on `; `
1. Convert each value to a [java.io.File](https://docs.oracle.com/javase/8/docs/api/java/io/File.html) instance
1. Call [File.getParentFile](https://docs.oracle.com/javase/8/docs/api/java/io/File.html#getParentFile--) to get a File object representing the parent directory.
1. Call [File.getPath](https://docs.oracle.com/javase/8/docs/api/java/io/File.html#getPath--) to get a string representing the directory path
1. Sort values, remove duplicative instances of any directory value, join values using `; `

### Item Set Duplicate Custodians

This field yields a list of custodians which have a duplicate of a given item in each of the item sets specified on the "Item Sets" tab.

### Item Set Custodians

Similar to "Item Set Duplicate Custodians", his field yields a list of custodians which have a duplicate of a given item in each of the item sets specified on the "Item Sets" tab.  This field differs from "Item Set Duplicate Custodians" in that it will also include the custodian assigned to a given item, not just custodians of the duplicates.

### Item Set Duplicate GUIDs

This field yields a list of GUIDs for items which are duplicates of a given item in each of the item sets specified on the "Item Sets" tab.

### Item Set Duplicate Paths

This field yields a list of item paths for items which are duplicates of a given item in each of the item sets specified on the "Item Sets" tab.

### Item Set Duplicate Item Dates

This field yields a list of item dates for items which are duplicates of a given item in each of the item sets specified on the "Item Sets" tab.

### Top Level MD5

For a given item, this field yields the MD5 value of that item's top level item, if it has one, or blank if the item does not have a top level item.  For items which are themself top level, this will yield the item's own MD5 value.

### Top Level SHA1

Exports a field with the SHA1 of an item's top level item (if it has one).

### Top Level SHA256

Exports a field with the SHA256 of an item's top level item (if it has one).

### Top Level DOCID

Exports a field with the DOCID(s) of a given item's top level item.  If a given item is itself top level, this yields a blank value.  DOCID(s) returned by this field are based upon which production sets are selected in the settings dialog.  So if **N** production sets are selected, this field may contain 0-**N** DOCIDs, depending on how many of those production sets the given item's top level item is a member of.  When a given item resolves to multiple DOCIDs, the value will contain a delimited list of DOCIDs.  If the given item has no top level item, this field's value will be blank.

### Has Production Set

For a given item, this field yields `true` or `false`.  `true` if the item is in at least one production set, otherwise `false`.

### Production Set Names

For a given item, this field yields a delimited list of production set names for all production sets in which this item is a member.

### Production Set GUIDs

For a given item, this field yields a delimited list of production set GUIDs (the GUID of the production set itself) for all production sets in which this item is a member.

### Production Set History

For a given item, lists a delimited list of when the given item was added or removed from a production set based on events present in the case history.  Example output:

```
Added to 'Prod 1' 2017-08-25T20:59:03.855Z; Added to 'Prod 3' 2017-08-25T21:59:00.825Z; Removed from 'Prod 1' 2017-08-25T22:03:50.055Z
```

**Important:** The work needed to collect the production set history information can take a long time upfront in a case with a large history!

### All Production Set DOCIDs

For a given item, this field yields a delimited list of DOCIDs for every production set this item is a member of.

### Select Production Set DOCIDs

For a given item, this field yields a delimited list of DOCIDs for specifically selected production set this item is a member of.  To determine which production sets are reported, select the relevant production sets in the production sets tab of the settings dialog.

### Descendant Names

For a given item, lists a delimited listing of the localised names of all descendants.

### Material Descendant Names

For a given item, lists a delimited listing of the localised names of all audited (AKA material) descendants.

### Descendant Count

For a given item, yields the count of descendants a given item has.

### Material Descendant Count

For a given item, yields the count of descendants a given item has which are audited (AKA material).

### All Custodians

Yields a delimited list of all custodians which have an MD5 duplicate of the given item.

### Top Level All Custodians

Yields a delimited list of all custodians which have a top level MD5 duplicate of the given item, if the item is itself top level

### Family Count

Yields the number of items in the family this item belongs to.

### Material Family Count

Yields the number of items in the family this item belongs to that are material/audited.

### Office Exceptions

Yields a delimited list of details relating to office document items based on metadata properties of those items.  Possible values that may show up in this field:

- `Contains Comments`
- `Contains Hidden Slides`
- `Contains Hidden Text`
- `Contains White Text`
- `Excel Hidden Columns`
- `Excel Hidden Rows`
- `Excel Hidden Sheets`
- `Excel Hidden Workbook`
- `Excel Protected Sheets`
- `Excel Very Hidden Sheets`
- `Excel Workbook Write Protected`
- `Excel Print Areas`
- `Track Changes`

### Physical File Ancestor Name

Yields the name of the physical file ancestor item, as would be found by the search `flag:physical_file`, if there is one.

### Physical File Ancestor MD5

Yields the MD5 digest of the physical file ancestor item, as would be found by the search `flag:physical_file`, if there is one.

### Child MD5 Hashes

Yields a delimited list containing the MD5 hash of all child items of a given item.

### Child SHA1 Hashes

Yields a delimited list containing the SHA1 hash of all child items of a given item.

### Child SHA256 Hashes

Yields a delimited list containing the SHA256 hash of all child items of a given item.

### Duplicate Custodians and Paths

Yields a delimited list of custodian and path of each duplicate of a given item.

### Item Set Paths

Yields a delimited list of paths for items which are a duplicate of a given item in select item sets, includes path of given item as well.

### Term Counts and Occurrences

Term counts for an item are how many distinct terms are present in a given set of text.  Term occurrences is a count of how many times a term occurs in a given set of text.  To demonstrate this with an example, imagine you have the following text:

```
The quick brown fox jumped over the lazy dogs.  The brown fox then hid among the dead brown grass.
```

| #  | Term        |  Occurrences |
|----|-------------|--------------|
| 1  | `The`       | 4            |
| 2  | `quick`     | 1            |
| 3  | `brown`     | 3            |
| 4  | `fox`       | 2            |
| 5  | `jumped`    | 1            |
| 6  | `over`      | 1            |
| 7  | `lazy`      | 1            |
| 8  | `dogs`      | 1            |
| 9  | `then`      | 1            |
| 10 | `hid`       | 1            |
| 11 | `among`     | 1            |
| 12 | `dead`      | 1            |
| 13 | `grass`     | 1            |
|    | **Total**   | 19           |

As you can see the example text above contains 13 distinct terms, but they occur overall a total of 19 times.  Nuix allows for collection of term statistics from either items' content text, properties or both.  Export Profile Plus offers several fields to report on term count and term occurrences for items:

- **Content Term Count**
- **Content Term Occurrences**
- **Properties Term Count**
- **Properties Term Occurrences**
- **Properties and Content Term Count**
- **Properties and Content Term Occurrences**

## Implementing New Fields

You may add your own custom fields with a little scripting work.  It would be beneficial to look at the existing implementations as reference.

Create a class which derives from the `CustomFieldBase` class defined in `CustomFieldBase.rb`.

### Required Method Overrides

In the least your class must implement the following:

- `name`: This method is expected to return the `name` of your custom field.  This value is used when listing the field in the GUI and as the header for the column the field is written to.
- `decorate`: This method will be provided an instance of  [MetadataProfile].  This method is expected to add a custom field to the profile and return the newly modified profile.  See [MetadataProfile.addMetadata] for details regarding this.  It is also recommended you review existing field definitions included with the script for examples of this.

### Optional Method Overrides

These methods can optionally be overridden in your custom class.  The provide additionally functionality if desired.

- `tool_tip`: You can optionally override this method.  This method is expected to return a string containing tool tip text to be shown in the GUI for the given field.
- `setup`: This method allows your field to perform any up front calculations it may need to perform before export begins.  This method will be provided the items the user selected before running the script.
- `cleanup`: This method allows your field to perform any post export cleanup it may need to perform.
- `dependencies`: Override this method and return an integer greater than 0 if your custom field should be calcuated after others (i.e. it has dependencies). Custom fields are sorted by the value returned by this method before being calculated.
- `needs_item_sets`: Override this method and return `true` if your custom field requires knowing what item sets the user checked on the "Item Sets" tab.  When any of the user specified fields returns `true` via this method then the settings dialog will enforce that the user select at least one item set.
- `needs_prod_sets`: Override this method and return `true` if your custom field requires knowing what production sets the user checked on the "Production Sets" tab.  When any of the user specified fields returns `true` via this method then the settings dialog will enforce that the user select at least one production set.

### Making it Visible

The script uses [introspection](https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=ruby%20introspection) to locate all the classes which derive from `CustomFieldBase`.  So there is no extra work that needs to be done to make script aware of your custom field except make sure your field class file is placed in the script's sub-directory `Fields`.

# License

```
Copyright 2018 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[Communication]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Communication.html
[Item.getCommunication]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Item.html#getCommunication--
[Address]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Address.html
[Item.getBinary]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Item.html#getBinary--
[Binary]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Binary.html
[Binary.getBinaryData]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Binary.html#getBinaryData--
[BinaryData]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/BinaryData.html
[BinaryData.getLength]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/BinaryData.html#getLength--
[Binary.getStoredPath]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Binary.html#getStoredPath--
[Item.getTextObject]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Item.html#getTextObject--
[Text]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Text.html
[Text.getStoredPath]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Text.html#getStoredPath--
[ItemUtility.intersection]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/ItemUtility.html#intersection-java.util.Collection-java.util.Collection-
[Text.toString]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Text.html#toString--
[MetadataProfile.addMetadata]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/MetadataProfile.html#addMetadata-java.lang.String-nuix.ItemExpression-
[MetadataProfile]: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/MetadataProfile.html
