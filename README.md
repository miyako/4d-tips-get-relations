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
