# Beef-Lang-XML
This is a script written in beeflang for xml usage.

How to use.

<-How to parse a file->

To parse an xml file, you need to pass the xml source through a lexer, to get some tokens. This can easely be done by calling

```csharp

using XML;

static void Main()
{
			String FileData = new String();

			File.ReadAllText(<XML path here>,FileData);
      
      var xml = new XMLFile();
      
      var tokens = XMLToken.ParseTokens(FileData);
      
      //You can access all the elements in this xml file by referencing "RootElements"
      
      //Dont forget to deallocate at end
      delete tokens;
      delete FileData;
      delete xml;
      
      //Removes string junk
      StringMethods.XMLEnd();
}

```

<-How to create an xml file->

My xml lib works off a tree system. You can have an array of XMLElement objects, and you can parent them for proper indexing.

For example.

```csharp

XMLElement God = new XMLElement("God",false); // You can create an xmlelement with the parameters (Name, Collapsed)

God.SetAttribute("Level","Above All"); // Also, you can set element attributes by calling SetAttribute (Attribute Name, Attribute Value)

Console.WriteLine(God);

//Output
//<God Level="Above All"></God>

```

```csharp

XMLElement God = new XMLElement("God",false); 

God.SetAttribute("Level","Above All"); 

XMLElement Human = new XMLElement("Human",false); 

Human.Parent = God;

Console.WriteLine(God);

//Output
//<God Level="Above All">
//  <Human></Human>
//</God>

```

To export just add your element to Root Elements of a XMLFile object, then call XMLFile.ExportToFile(Path)

!!Make sure to call StringMethods.XMLEnd() to clear all the collected garbage.
