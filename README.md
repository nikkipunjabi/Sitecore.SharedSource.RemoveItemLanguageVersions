# Sitecore - Remove Item Language Versions

Are you working on a Multi-lingual Site having more than one languages and want to remove the item language versions of many Sitecore items? If yes then you are at right place.

If content authors are working on many items and if they remove language versions manually then for each it will take hours of them to do it. This tool will help content authors to remove the unnecessary language versions from the Sitecore Items.

![Remove Item Language Versions](http://www.nikkipunjabi.com/Sitecore/RemoveItemLanguageVersions/3.png "Remove Item Language Versions")

Remove Item Language Versions:
  - Sitecore Core DB Items: 
    - /sitecore/content/Applications/Remove Item Language Versions
    - /sitecore/content/Documents and settings/All users/Start menu/Programs/Remove Item Language Versions
  - Files:
    - /sitecore/admin/removeitemlanguageversions.aspx

If you are developing/implementing the same and looking for a piece of source code:

```sh
Language languageRemove = Sitecore.Globalization.Language.Parse(languageCode);
Item rootItem = db.GetItem(rootItemPath, languageRemove);
if (rootItem != null)
{
	using (new Sitecore.SecurityModel.SecurityDisabler())
	{
		if (rootItem.Versions.Count == 0)
        {
			sb.Append("Language version not found. Item: " + rootItemPath).Append(" Language: ").Append(languageCode).Append("<br/>");
        }
        else
        {
            //Remove All Versions from Item
            rootItem.Versions.RemoveAll(false);                   
		}
	}
}
```

In this tool, you need to provide the Sitecore Item IDs or Paths separated in a line and select the langauges which you want to remove from the items and click Remove. 

> Note: This will remove all the versions of the selected language.

I've provided the access only to Administrators, so this tool can only be accessed by Administrators, but if you want to provide the access Content Authors then you can update as required or let me know, i'll update and provide you. :)

### Screenshots:
![Output](http://www.nikkipunjabi.com/Sitecore/RemoveItemLanguageVersions/1.png "Output")
![Output](http://www.nikkipunjabi.com/Sitecore/RemoveItemLanguageVersions/2.png "Output")

Thanks for reading this post and let me know if you face any issues.
You can anytime download the repository and update the module or let me know if you want any updates/changes.

Happy Sitecoring! :)
