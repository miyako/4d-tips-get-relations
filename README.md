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

## The Class

Here is a reference implementation that uses XPath to parse the catalog and find relations.

```4d
property xml : Text

Class constructor($catalog : Object)
	
	Case of 
		: ($catalog=Null)
			var $catalogXml : Text
			EXPORT STRUCTURE($catalogXml)
			This.xml:=$catalogXml
		: (OB Instance of($catalog; 4D.File)) && ($catalog.exists)
			This.xml:=$catalog.getText()
	End case 
	
Function _getField($dom : Text; $uuid : Text) : Object
	
	var $xpath; $field; $table : Text
	$xpath:="/base/table/field[@uuid='"+$uuid+"']"
	$field:=DOM Find XML element($dom; $xpath)
	
	If (OK=1)
		var $name : Text
		var $id : Integer
		var $t; $f : Object
		DOM GET XML ATTRIBUTE BY NAME($field; "name"; $name)
		DOM GET XML ATTRIBUTE BY NAME($field; "id"; $id)
		$t:={}
		$f:={name: $name; uuid: $uuid; id: $id; table: $t}
		$table:=DOM Get parent XML element($field)
		DOM GET XML ATTRIBUTE BY NAME($table; "name"; $name)
		DOM GET XML ATTRIBUTE BY NAME($table; "uuid"; $uuid)
		DOM GET XML ATTRIBUTE BY NAME($table; "id"; $id)
		$t.name:=$name
		$t.uuid:=$uuid
		$t.id:=$id
		return $f
	End if 
	
Function getNto1($tableName : Text; $fieldName : Text) : Object
	
	return This.get($tableName; $fieldName; "source"; "destination")
	
Function get1toN($tableName : Text; $fieldName : Text) : Object
	
	return This.get($tableName; $fieldName; "destination"; "source")
	
Function get($tableName : Text; $fieldName : Text; $a : Text; $b : Text) : Object
	
	var $field : Object
	
	var $catalog : Text
	$catalog:=This.xml
	
	If ($catalog#"")
		ARRAY TEXT($nodes; 0)
		var $dom; $xpath; $uuid : Text
		$dom:=DOM Parse XML variable($catalog)
		$xpath:="/base/table[@name='"+$tableName+"']/field[@name='"+$fieldName+"']"
		CLEAR VARIABLE($nodes)
		$node:=DOM Find XML element($dom; $xpath; $nodes)
		If (OK=1)
			DOM GET XML ATTRIBUTE BY NAME($node; "uuid"; $uuid)
			$source:=This._getField($dom; $uuid)
			$relations:=[]
			$field:={field: $source; relations: $relations}
			$xpath:="/base/relation/related_field[@kind='"+$a+"']/field_ref[@uuid='"+$uuid+"']"
			CLEAR VARIABLE($nodes)
			$node:=DOM Find XML element($dom; $xpath; $nodes)
			If (OK=1)
				var $mm : Collection
				$mm:=[]
				ARRAY TO COLLECTION($mm; $nodes)
				For each ($node; $mm)
					$xpath:="../../related_field[@kind='"+$b+"']/field_ref"
					$node:=DOM Find XML element($node; $xpath; $nodes)
					If (OK=1)
						DOM GET XML ATTRIBUTE BY NAME($node; "uuid"; $uuid)
						$relations.push(This._getField($dom; $uuid))
					End if 
				End for each 
			End if 
		End if 
		DOM CLOSE XML($dom)
	End if 
	
	return $field
```

> [!TIP]
> In 4D 20 R5 and later, you can use [shared singletons](https://blog.4d.com/singletons-in-4d/) to instantiate a class just once and retain static properties (such as the root DOM reference in this example). 

Relations can be found based on the table name and field name.

```4d
var $catalog : cs.Catalog
$catalog:=cs.Catalog.new()
$relations:=$catalog.get1toN("Table_1"; "Field_2")  //1toN relations to this field
```

* Result

```json
{
	"field": {
		"name": "Field_2",
		"uuid": "9F7017EE2410485B94260D2625AA912E",
		"id": 2,
		"table": {
			"name": "Table_1",
			"uuid": "3EB58544BE2840378A501A88541CE96E",
			"id": 1
		}
	},
	"relations": [
		{
			"name": "Field_2",
			"uuid": "7AC800F9A48640F2A40C96E907B3D1A1",
			"id": 2,
			"table": {
				"name": "Table_2",
				"uuid": "B094561C9C8E45F5933F3EF455978199",
				"id": 2
			}
		},
		{
			"name": "Field_2",
			"uuid": "F91C8247EBE6412E95F2796484B3FD3D",
			"id": 2,
			"table": {
				"name": "Table_3",
				"uuid": "985DD41A7EBF4724AF753885A6E223FB",
				"id": 3
			}
		}
	]
}
```

```4d
$relations:=$catalog.getNto1("Table_3"; "Field_2")  //Nto1 relations from this field
```

```json
{
	"field": {
		"name": "Field_2",
		"uuid": "F91C8247EBE6412E95F2796484B3FD3D",
		"id": 2,
		"table": {
			"name": "Table_3",
			"uuid": "985DD41A7EBF4724AF753885A6E223FB",
			"id": 3
		}
	},
	"relations": [
		{
			"name": "Field_2",
			"uuid": "9F7017EE2410485B94260D2625AA912E",
			"id": 2,
			"table": {
				"name": "Table_1",
				"uuid": "3EB58544BE2840378A501A88541CE96E",
				"id": 1
			}
		}
	]
}
```
