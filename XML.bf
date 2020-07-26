using System;
using System.Collections;
using System.IO;

namespace XML
{
	public static class StringMethods
	{
		public static void DeleteStringAllocationList(List<String> list)
		{
			for (String s in list)
			{
				delete s;
			}

			delete list;
		}

		public static List<String> Split(String source,char8 splitter)
		{
			List<String> Temp = new List<String>();

			String temp = new String();

 			for (int i = 0; i < source.Length; i++)
			{
				if (source[i] == splitter)
				{
					Temp.Add(new String(temp));

					delete temp;

					temp = new String();
				}
				else
				{
					temp.Append(source[i]);
				}
			}

			Temp.Add(new String(temp));

			delete temp;

			return Temp;
		}

		public static List<String> StringAllocationGarbage = new List<String>();

		public static void XMLEnd()
		{
			DeleteStringAllocationList(StringAllocationGarbage);
		}

		public static String CreateString(String str)
		{
			String Out = new String(str);

			StringAllocationGarbage.Add(Out);

			return Out;
		}
	}	

	public class XMLElement
	{
		//The name of the element 
		public String ElementName;

		//Attributes of the element
		Dictionary<String,String> Attributes = new Dictionary<String, String>();

		//This is used because i have no idea how to get all the keys from a dictionary :(
		List<String> AllAttributes = new List<String>();

		// "<Name/>" this is closed, "<Name></Name>" this is not
		public bool Closed;

		//This is the data outside of an element
		public List<String> Data = new List<String>();

		//Init 
		public this(String ElementName,bool Closed = false)
		{
			this.Closed = Closed;
			this.ElementName = ElementName;
		}

		public this()
		{

		}

		//Returns the value of an attribute in the element 
		public String GetAttribute(String name)
		{
			return Attributes[name];
		}

		//Sets the attribute value inside an element 
		public void SetAttribute(String name, String value)
		{
			if (!ContainsAttribute(name))
			{
				Attributes.Add(name,null);

				AllAttributes.Add(name);
			}

			Attributes[name] = value;
		}

		//Removes attribute from the element 
		public void RemoveAttribute(String name)
		{
			if (ContainsAttribute(name))
			{
				Attributes.Remove(name);

				AllAttributes.Remove(name);
			}
		}

		//Checks if attribute is inside element 
		public bool ContainsAttribute(String name)
		{
			return Attributes.ContainsKey(name);
		}

		//Element Tree logic 
		XMLElement parent;
		public XMLElement Parent
		{
			get => parent;

			set mut
			{
				if (parent != null)
					parent.Children.Remove(this);

				parent = value;

				if (parent != null)
					parent.Children.Add(this);
			}	
		}

		List<XMLElement> Children = new List<XMLElement>();

		//Converts the element into a string, with all the children and data.
		public override void ToString(String strBuffer)
		{
			strBuffer.Append("<");
			strBuffer.Append(ElementName);

			for (String s in AllAttributes)
			{
				strBuffer.Append(" ");
				strBuffer.Append(s);
				strBuffer.Append("=\"");
				strBuffer.Append(Attributes[s]);
				strBuffer.Append("\"");
			}

			if (Closed)
			{
				strBuffer.Append("/>");
			}
			else
			{
				strBuffer.Append(">");

				if (Children.Count != 0)
					strBuffer.Append("\n");

				for (int i = 0; i < Data.Count; i++)
				{
					strBuffer.Append(Data[i]);

					if (i != Data.Count - 1)
					strBuffer.Append(" ");
				}

				for (XMLElement c in Children)
				{
					String temp = new String();

					c.ToString(temp);

					List<String> ToBeIndentedChildBuffer = StringMethods.Split(temp,'\n');

					for (int i = 0; i < ToBeIndentedChildBuffer.Count; i++)
					{
						String indent = new String("  ");

						indent.Append(ToBeIndentedChildBuffer[i]);

						strBuffer.Append(indent);
						strBuffer.Append("\n");

						delete indent;
					}

					StringMethods.DeleteStringAllocationList(ToBeIndentedChildBuffer);

					delete temp;
					delete c;
				}

				strBuffer.Append("</");
				strBuffer.Append(ElementName);
				strBuffer.Append(">");
			}
		}

		//Deallocates ALL elements that are scoapable from this element, including this.
		public void Clear()
		{
			for (XMLElement element in Children)
			{
				element.Clear();
			}

			delete this;
		}

		//Deallocation
		public ~this()
		{
			delete Attributes;
			delete AllAttributes;
			delete Children;
			delete Data;
		}
	}

	public class XMLFile
	{
		//The elements at the top of the tree 
		public List<XMLElement> RootElements = new List<XMLElement>();

		//Exports the xml
		public void ExportToFile(String path)
		{
			String Final = new String();

			for (XMLElement element in RootElements)
			{
				element.ToString(Final);
			}

			File.WriteAllText(path,Final);

			delete Final;
		}

		//Get XML file from parsed tokens 
		public void ParseFromTokens(List<XMLToken> Tokens)
		{
			XMLElement[] Indexers = new XMLElement[10000];

			int Index = 0;

			bool InElement = false;
			XMLElement CurrentElement = null;

			bool InElementSpace = false;

			for (int i = 0; i < Tokens.Count; i++)
			{
				XMLToken CurrentToken = Tokens[i];

				if (CurrentToken.Source == "<")
				{
					InElementSpace = true;

					if (Tokens[i + 1].Source == "/")
					{
						Index--;

						InElement = false;
					}
					else
					{
						Index++;

						InElement = true;

						CurrentElement = new XMLElement();
						Indexers[Index] = CurrentElement;

						CurrentElement.ElementName = Tokens[i + 1].Source;

						for (int c = i + 2; Tokens[c].Type != XMLToken.TokenType.Indexer; c++)
						{
							XMLToken current = Tokens[c];

							if (current.Type != XMLToken.TokenType.String && current.Type != XMLToken.TokenType.Operator)
							{
								CurrentElement.SetAttribute(current.Source,Tokens[c + 2].Source);
							}
						}

						if (Index - 1 == 0)
						{
							RootElements.Add(CurrentElement);
						}
						else
						{
							CurrentElement.Parent = Indexers[Index - 1];
						}
					}
				}

				if (CurrentToken.Source == ">")
				{
					InElementSpace = false;

					if (Tokens[i - 1].Source == "/")
					{
						Index--;

						InElement = false;

						CurrentElement.Closed = true;
					}
				}

				if (!InElementSpace && CurrentToken.Type == XMLToken.TokenType.Unknown)
				{
					CurrentElement.Data.Add(CurrentToken.Source);
				}
			}

			Console.WriteLine(Index);

			delete Indexers;
		}	

		//Deallocates ALL elements that are scoapable from this file
		public void ClearMemory()
		{
			for (XMLElement element in RootElements)
			{
				element.Clear();
			}
		}

		public ~this()
		{
			delete RootElements;
		}
	}

	//Parsing
	public struct XMLToken
	{
		//Self Explanatory 
		public enum TokenType
		{
			String,
			Indexer,
			Operator,
			Unknown
		}

		//Parse tokens from string source
		public static List<XMLToken> ParseTokens(String source)
		{
			List<XMLToken> Out = new List<XMLToken>();

			bool InElement = false;
			bool InString = false;

			String TempBuffer = new String();

			void AddChar(char8 char)
			{
				TempBuffer.Append(char);
			}

			void ClearTemp()
			{
				delete TempBuffer;

				TempBuffer = new String();
			}

			void CheckFullString()
			{
				if (TempBuffer != "")
				{
					Out.Add(XMLToken(StringMethods.CreateString(TempBuffer),TokenType.Unknown));
				}
			}

			for (int i = 0; i < source.Length; i++)
			{
				char8 c = source[i];

				if (!InString)
				{
					if (c == '"')
					{
						CheckFullString();

						ClearTemp();

						InString = true;
					}
					else if (c == '<')
					{
						CheckFullString();

						ClearTemp();

						InElement = true;

						Out.Add(XMLToken("<",TokenType.Indexer));
					}
					else if (InElement)
					{
						if (c == '>')
						{
							CheckFullString();

							ClearTemp();

							InElement = false;

							Out.Add(XMLToken(">",TokenType.Indexer));
						}
						else if (c == '/')
						{
							CheckFullString();

							ClearTemp();

							Out.Add(XMLToken("/",TokenType.Indexer));
						}
						else if (c == '=')
						{
							CheckFullString();

							ClearTemp();

							Out.Add(XMLToken("=",TokenType.Operator));
						}
						else if (c == ' ' || c == '\t' || c == '\n' || c == (char8)13)
						{
							CheckFullString();

							ClearTemp();
						}
						else
						{
							TempBuffer.Append(c);
						}

					}
					else if (c == ' ' || c == '\t' || c == '\n' || c == (char8)13)
					{
						CheckFullString();

						ClearTemp();
					}
					else
					{
						TempBuffer.Append(c);
					}
					
				}
				else
				{
					if (c == '"')
					{
						Out.Add(XMLToken(StringMethods.CreateString(TempBuffer),TokenType.String));

						ClearTemp();

						InString = false;
					}
					else
					{
						AddChar(c);
					}
				}	
			}

			delete TempBuffer;

			return Out;
		}

		public String Source;
	    public TokenType Type;

		public this(String source, TokenType type)
		{
			this.Source = source;
			this.Type = type;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("{");
			strBuffer.Append(Source);
			strBuffer.Append(" , ");
			Type.ToString(strBuffer);
			strBuffer.Append("}");
		}
	}
}
