{include file="pageheader.tpl"}
{insert_scripts files="skyuc_listtable.js"}
<form method="post" onsubmit="return false">
<div class="form-div">
  {$lang.select_library}
  <select class="textCtrl"  id="selLib" onchange="loadLibrary()">{$curr_template}
    {html_options options=$libraries selected="$curr_library"}
  </select>
</div>

<div class="main-div">
  <div class="button-div ">
  <textarea class="textCtrl" id="libContent" style='width:99%;height:450px;word-wrap: break-word;word-break:break-all;'>{$library_html|escape:html}</textarea>
    <input type="button" class="button"  value="{$lang.button_submit}"  onclick="updateLibrary()" />
    <input type="button" class="button"  value="{$lang.button_restore}"  onclick="restoreLibrary()" />
  </div>
</div>
</form>
<script language="JavaScript">
<!--
var currLibrary = "{$curr_library}";
var content = '';
onload = function()
{
    document.getElementById('libContent').focus();

}

/**
 * 载入库项目内容
 */
function loadLibrary()
{
    curContent = document.getElementById('libContent').value;

    if (content != curContent && content != '')
    {
        if (!confirm(save_confirm))
        {
            return;
        }
    }

    selLib  = document.getElementById('selLib');
    currLib = selLib.options[selLib.selectedIndex].value;

    Ajax.call('template.php?is_ajax=1&act=load_library', 'lib='+ currLib, loadLibraryResponse, "GET", "JSON");
}

/**
 * 还原库项目内容
 */
function restoreLibrary()
{
    selLib  = document.getElementById('selLib');
    currLib = selLib.options[selLib.selectedIndex].value;

    Ajax.call('template.php?is_ajax=1&act=restore_library', "lib="+currLib, loadLibraryResponse, "GET", "JSON");
}

/**
 * 处理载入的反馈信息
 */
function loadLibraryResponse(result)
{
    if (result.error == 0)
    {
        document.getElementById('libContent').value=result.content;
    }

    if (result.message.length > 0)
    {
      alert(result.message);
    }
}

/**
 * 更新库项目内容
 */
function updateLibrary()
{
    selLib  = document.getElementById('selLib');
    currLib = selLib.options[selLib.selectedIndex].value;
    content = document.getElementById('libContent').value;

    if (Utils.trim(content) == "")
    {
        alert(empty_content);
        return;
    }
    Ajax.call('template.php?act=update_library&is_ajax=1', 'lib=' + currLib + "&html=" + encodeURIComponent(content), updateLibraryResponse, "POST", "JSON");
}

/**
 * 处理更新的反馈信息
 */
function updateLibraryResponse(result)
{
  if (result.message.length > 0)
  {
    alert(result.message);
  }
}

//-->
</script>
{include file="pagefooter.tpl"}
