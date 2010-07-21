if(!kopal.page)
  kopal.page = {};

kopal.page.widget_canvas_url = kopal.identity + 'home/widget_canvas';

kopal.page.ShowSelectWidgetPage = function()
{
  YUI().use("node", "selector-css3", function(Y) {
    Y.one('body').appendChild(
      Y.Node.create('<div id="PageOverlayBackground"></div>').
        setStyle('position', 'absolute').
        setStyle('top', '0').
        setStyle('bottom', '0').
        setStyle('left', '0').
        setStyle('right', '0').
        setStyle('height', '100%'). //FIXME: Still only shadows the "showing" part of a scrollable page.
        setStyle('width', '100%').
        setStyle('background-color', 'black').
        setStyle('z-index', '1001').
        setStyle('opacity', '0.8'));
    var overlay = Y.one("#PageSelectWidgetForm");
    overlay.setStyle('display', 'block'). //Should be removing 'display' CSS attribute from element. How to?
      setStyle('position', 'absolute').
      setStyle('top', '0').
      setStyle('background-color', 'white').
      setStyle('z-index', '1002');
    Y.one('body').appendChild(overlay);
  });
}

kopal.page.CloseSelectWidgetPage = function()
{
  YUI().use('node', 'selector-css3', function(Y){
    Y.one('#PageOverlayBackground').remove();
    Y.one('#PageSelectWidgetForm').setStyle('display', 'none')
  });
}

kopal.page.CreateCanvasForWidget = function(widget_key, widget_url)
{
  YUI().use('node', 'selector-css3', function(Y){
    var page_edit = Y.one("#PageEdit");
    var iframe_tag = Y.Node.create('<iframe />');
    iframe_tag.set('id', 'WidgetCanvas_' + widget_key);
    iframe_tag.setAttribute('seamless', 'seamless'); //This should be implemented by browsers ASAP.
    iframe_tag.setStyle('width', '100%').
      setStyle('height', '400px'). //Should be auto to iframe's length
      setStyle('border', 'none');
    //TODO: Use "srcdoc" later, and we set variables within document like widget_key in a <meta />? (or window.postMessage).
    iframe_tag.setAttribute('src', kopal.page.widget_canvas_url + 
      //Using # instead of ? so that browser can supply from cache.
      //TODO: Use window.postMessage() instead.
      '#mode=edit;widget_key=' + widget_key + ';widget_url=' + encodeURIComponent(encodeURIComponent(widget_url)) );
    page_edit.appendChild(iframe_tag);
  });
}