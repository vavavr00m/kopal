if(!kopal.widget)
  kopal.widget = {};

kopal.widget.RetrieveWidgetParameters = function() {
  s = window.location.hash;
  s = s.substring(1, s.length);
  s = s.toQueryParams(';');
  kopal.widget.mode = s.mode;
  kopal.widget.widget_key = s.widget_key;
  kopal.widget.widget_url = decodeURIComponent(s.widget_url);
}

kopal.widget.GetRecordActionUrl = function(widget_key, name) {
  if(widget_key == null)
    widget_key = kopal.widget.widget_key
  return kopal.identity + 'widget_record/' + '?widget_key=' + widget_key + '&name=' + name;
}

//TODO: Deprecate this in favour of GetRecords.
kopal.widget.GetRecord = function(widget_key, name, callback) {
  if(widget_key == null)
    widget_key = kopal.widget.widget_key
  new Ajax.Request(kopal.widget.GetRecordActionUrl(widget_key, name), {
    onComplete: callback,
    method: 'get'
  })
}
//GET multiple records in one request. Server should return JSON.
//This function should return parsed JSON.
//Example - GetRecords(['heading', 'note'], callback)
//Example - GetRecords([{widget_key: abcd, name: note}, {...}], callback)
kopal.widget.GetRecords = function() {}

//Returns false if does not, or scope as integer.
//NOTE: Returns 0 and false with different meanings.
kopal.widget.RecordExists = function(widget_key, name, callback) {
  //TODO: Write me.
  //Need this method?
}

kopal.widget.CreateRecord = function(widget_key, name, value, callback) {
  new Ajax.Request(kopal.widget.GetRecordActionUrl(widget_key, name), {
    onComplete: callback,
    method: 'post',
    parameters: 'value=' + value
  })
}

//Create or Update a record
kopal.widget.UpdateRecord = function(widget_key, name, value, callback) {
  new Ajax.Request(kopal.widget.GetRecordActionUrl(widget_key, name), {
    onComplete: callback,
    method: 'put',
    parameters: 'value=' + value
  })
}


kopal.widget.DeleteRecord = function(widget_key, name) {
  new Ajax.Request(kopal.widget.GetRecordActionUrl(widget_key, name), {
    onComplete: callback,
    method: 'delete'
  })
}