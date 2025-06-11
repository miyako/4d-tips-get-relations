![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)

# 4d-tips-get-relations
Example of using xpath for catalog introspection

## The Structure

<img src="https://github.com/user-attachments/assets/b7664198-3478-4b71-8110-a606a2bd8a90" width=500 height=auto />

In this example, we have 3 tables, 2 links.

* `Table_1` is the **one** table to `Table_2` and `Table_3`.
* `Table_2` and `Table_3` are the **many** tables to `Table_1`.

## The Catalog

The schema of a 4D database is stored in the `catalog.4DCatalog` file of a project, or inside the `.4DB` or `.4DC` structure file of a binary project. The [`EXPORT STRUCTURE`](https://developer.4d.com/docs/commands/export-structure) command returns the schema is returned in XML format.

> [!TIP]
> Starting with 4D 20 R4, the command can alternatively [export the schema in HTML format](https://blog.4d.com/structure-definition-export-in-html/).

## The XML

The database scheme is described in XML format. You can use the [DOM Find XML element](https://developer.4d.com/docs/commands/dom-find-xml-element) command with standard XPath to query information.

> [!WARNING]
> The revised [XPath](https://developer.4d.com/docs/commands/dom-set-xml-element-value) support of [4D 18 R3](https://blog.4d.com/enhanced-xpath-support/) can potentially break legacy code; in previous versions, the path started with the element name of the current node, which would match a child element name in standard XPath. See [Support of XPath notation (DOM)](https://doc.4d.com/4Dv20/4D/20.6/Overview-of-XML-DOM-Commands.300-7487227.en.html#4967352). The [Use standard XPath](https://developer.4d.com/docs/settings/compatibility) compatibility option must be explicitly activated in legacy projects. 
