//TODO: Prefer YUI over jQquery. I'd like to use YUI but jQuery is what I know now. 
if(!kopal)
  var kopal = {};
//I probably need to shift to standardJavaScriptNamingConvention in future for consistency.
//From PascalNotation and under_score to camelCase.

kopal.random = function(size)
{
  size = size || 4; //0 to 9999 by default.
	return Math.round(Math.random()*size*10);
}

/*
 * Function to show a spinner.
 * returns the (string) id of the spinner.
 * If no spinner id is defined, generates a random one.
 * Parameters can also be passed as an object
 * Example : {element_id: 'ElementID', insert_at: 'Top', wait_text: 'Downloading....', spinner_id: 1234}
 * parameters except element_id are optional.
*/
kopal.spinner = function(element_id, /* optional */insert_at, wait_text, spinner_id)
{
	if(arguments[0] instanceof Object && arguments.length == 1)
	{
		insert_at = arguments[0].insert_at;
		wait_text = arguments[0].wait_text;
		spinner_id = arguments[0].spinner_id;
		element_id = arguments[0].element_id; //At last
	}
	insert_at = insert_at || "Top";
	wait_text = wait_text || "Please wait....";
	spinner_id = spinner_id || kopal.random(4);
	spin = '<div id="Spinner_' + spinner_id + '"><img src="' + kopal.route.root + 
    'home/image/ajax-spinner.gif" alt="Working...." title="Please wait.." style="display:inline;" />' +
    wait_text + '</div>'
	new Insertion[insert_at](element_id, spin);
	return 'Spinner_' + spinner_id;
}

//TODO: Deprecate in favour of some YUI method, if YUI has such functionality.
kopal.IncludeScriptTag = function(src_url) {
  YUI().use('node', function(Y) {
    var rand;
    if(kopal.RAILS_ENV == 'development')
        rand = '?' + Math.random()
    var tag = Y.Node.create("<script></script>");
    tag.setAttribute("type", "text/javascript").
      setAttribute("src", src_url + rand);
    Y.one('head').appendChild(tag);
  })
}