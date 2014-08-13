{include file="pageheader.tpl"}

<div class="form-div">
  <form name="searchForm" action="edit_languages.php" method="post" onSubmit="return validate();">
    <select class="textCtrl"  name="lang_file">{html_options options=$lang_arr selected=$lang_file}</select>
    &nbsp;&nbsp;&nbsp;
    {$lang.enter_keywords}：<input type="text" name="keyword" size="30" />
    <input type="submit" class="button primary submitButton" value="{$lang.button_search}"  /> <input type="hidden" name="act" value="list" />
  </form>
</div>
<div>
<ul style="padding:0; margin: 0; list-style-type:none; color: #CC0000;">
  {if $file_attr}
  <li style="border: 1px solid #CC0000; background: #FFFFCC; padding: 10px; margin-bottom: 5px;" >{$file_attr}</li>
  {/if}
</ul>
</div>

<form method="post" action="edit_languages.php">
<div class="list-div" id="listDiv">
<table width="100%" cellspacing="1" cellpadding="2" id="list-table">
{if $language_arr}
  <tr>
    <th>{$lang.item_name}</th>
    <th>{$lang.item_value}</th>
  </tr>
 {foreach from=$language_arr item=list}
  <tr>
    <td width="30%" align="left" class="first-cell">
    {$list.item_id}<input type="hidden" name="item_id[]" value="{$list.item_id}" />
    </td>
    <td width="70%">
      <input type="text"  name="item_content[]" value="{$list.item_content|escape:html}" size="60" />
    </td>
  </tr>
  <tr style="display:none">
    <td width="30%" align="left" class="first-cell">&nbsp;</td>
    <td width="70%">
      <input type="hidden" name="item[]" value="{$list.item|escape:html}" size="60"/>
    </td>
  </tr>
  {/foreach}
  <tr>
    <td colspan="2">
      <div align="center">
        <input type="hidden" name="act" value="edit" />
        <input type="hidden" name="file_path" value="{$file_path}" />
        <input type="hidden" name="keyword" value="{$keyword}" />
        <input type="submit" class="button primary submitButton" value="{$lang.edit_button}"  />
&nbsp;&nbsp;&nbsp;
        <input type="reset" class="button submitButton"  value="{$lang.reset_button}"  />
      </div></td>
    </tr>
  <tr>
    <td colspan="2"><strong>{$lang.notice_edit}</strong></td>
    </tr>
  {/if}

</table>
</div>
</form>


<script type="text/javascript" language="JavaScript">
<!--

onload = function()
{
    document.forms['searchForm'].elements['keyword'].focus();
}

function validate()
{
    var frm     = document.forms['searchForm'];
    var keyword = frm.elements['keyword'].value;
    if (keyword.length == 0)
    {
        alert(keyword_empty_error);

        return false;
    }
    return true;
}
//-->
</script>

{include file="pagefooter.tpl"}
