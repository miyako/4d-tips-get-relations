property xml : Text

Class constructor($catalog : Object)
	
	Case of 
		: ($catalog=Null:C1517)
			var $catalogXml : Text
			EXPORT STRUCTURE:C1311($catalogXml)
			This:C1470.xml:=$catalogXml
		: (OB Instance of:C1731($catalog; 4D:C1709.File)) && ($catalog.exists)
			This:C1470.xml:=$catalog.getText()
	End case 
	
Function _getField($dom : Text; $uuid : Text) : Object
	
	var $xpath; $field; $table : Text
	$xpath:="/base/table/field[@uuid='"+$uuid+"']"
	$field:=DOM Find XML element:C864($dom; $xpath)
	
	If (OK=1)
		var $name : Text
		var $id : Integer
		var $t; $f : Object
		DOM GET XML ATTRIBUTE BY NAME:C728($field; "name"; $name)
		DOM GET XML ATTRIBUTE BY NAME:C728($field; "id"; $id)
		$t:={}
		$f:={name: $name; uuid: $uuid; id: $id; table: $t}
		$table:=DOM Get parent XML element:C923($field)
		DOM GET XML ATTRIBUTE BY NAME:C728($table; "name"; $name)
		DOM GET XML ATTRIBUTE BY NAME:C728($table; "uuid"; $uuid)
		DOM GET XML ATTRIBUTE BY NAME:C728($table; "id"; $id)
		$t.name:=$name
		$t.uuid:=$uuid
		$t.id:=$id
		return $f
	End if 
	
Function getNto1($tableName : Text; $fieldName : Text) : Object
	
	return This:C1470.get($tableName; $fieldName; "source"; "destination")
	
Function get1toN($tableName : Text; $fieldName : Text) : Object
	
	return This:C1470.get($tableName; $fieldName; "destination"; "source")
	
Function get($tableName : Text; $fieldName : Text; $a : Text; $b : Text) : Object
	
	var $field : Object
	
	var $catalog : Text
	$catalog:=This:C1470.xml
	
	If ($catalog#"")
		ARRAY TEXT:C222($nodes; 0)
		var $dom; $xpath; $uuid : Text
		$dom:=DOM Parse XML variable:C720($catalog)
		$xpath:="/base/table[@name='"+$tableName+"']/field[@name='"+$fieldName+"']"
		CLEAR VARIABLE:C89($nodes)
		$node:=DOM Find XML element:C864($dom; $xpath; $nodes)
		If (OK=1)
			DOM GET XML ATTRIBUTE BY NAME:C728($node; "uuid"; $uuid)
			$source:=This:C1470._getField($dom; $uuid)
			$relations:=[]
			$field:={field: $source; relations: $relations}
			$xpath:="/base/relation/related_field[@kind='"+$a+"']/field_ref[@uuid='"+$uuid+"']"
			CLEAR VARIABLE:C89($nodes)
			$node:=DOM Find XML element:C864($dom; $xpath; $nodes)
			If (OK=1)
				var $mm : Collection
				$mm:=[]
				ARRAY TO COLLECTION:C1563($mm; $nodes)
				For each ($node; $mm)
					$xpath:="../../related_field[@kind='"+$b+"']/field_ref"
					$node:=DOM Find XML element:C864($node; $xpath; $nodes)
					If (OK=1)
						DOM GET XML ATTRIBUTE BY NAME:C728($node; "uuid"; $uuid)
						$relations.push(This:C1470._getField($dom; $uuid))
					End if 
				End for each 
			End if 
		End if 
		DOM CLOSE XML:C722($dom)
	End if 
	
	return $field