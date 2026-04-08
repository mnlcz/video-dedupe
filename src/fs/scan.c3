module video_dedupe::fs;

import std::os;
import std::io::path;

<*
 Gets the items present in a path.
 @param allocator : `The allocator to use.`
 @param root : "The location to list its items. Already validated."
 @return "PathList instance containing the elements of the directory."
*>
fn PathList list_dir(Allocator allocator, Path root)
{
	return path::ls(allocator, root)!!;
}

<*
 Gets the items present in a path, using the temporary allocator.
 @param root : "The location to list its items. Already validated."
 @return "PathList instance containing the elements of the directory."
*>
fn PathList tlist_dir(Path root)
{
	return path::ls(tmem, root)!!;
}
