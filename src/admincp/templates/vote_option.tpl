{if $full_page}
{include file="pageheader.tpl"}
{insert_scripts files="skyuc_listtable.js"}

<div class="form-div">
<form method="post" action="javascript:newVoteOption()" name="theForm">
    {$lang.add_vote_option}：<input type="text"   name="option_name" maxlength="100" size="30" />
    <input type="hidden" name="id" value="{$id}" size="30" />
    <input type="submit" class="button primary submitButton" value="{$lang.button_submit}"  />
</form>
</div>

<!-- start option list -->
<div class="list-div" id="listDiv">
{/if}

<table cellspacing='1' cellpadding='3' id='listTable'>
  <tr>
    <th>{$lang.option_name}</th>
    <th>{$lang.vote_count}</th>
    <th>{$lang.handler}</th>
  </tr>
  {foreach from=$option_arr  item=list}
    <tr align="center">
      <td align="left" class="first-cell">
      <span onclick="javascript:listTable.edit(this, 'edit_option_name', {$list.option_id})">{$list.option_name|escape:"html"}</span>
      </td>
      <td>{$list.option_count}</td>
      <td><a href="javascript:;" onclick="listTable.remove({$list.option_id}, '{$lang.drop_confirm}', 'remove_option')" title="{$lang.remove}"><img src="images/icon_drop.gif" border="0" height="16" width="16"></a>
      </td>
    </tr>
  {/foreach}
</table>

{if $full_page}
</div>

<script language="JavaScript">

onload = function()
{
  document.forms['theForm'].elements['option_name'].focus();
}

function newVoteOption()
{
  var option_name = Utils.trim(document.forms['theForm'].elements['option_name'].value);
  var id          = Utils.trim(document.forms['theForm'].elements['id'].value);

  if (Utils.trim(option_name).length > 0)
  {
    Ajax.call('vote.php?is_ajax=1&act=new_option', 'option_name=' + option_name +'&id=' + id, newTypeResponse, "POST", "JSON");
  }else
  {
		alert(option_name_empty);
  }
}

function newTypeResponse(result)
{
  if (result.error == 0)
  {
    document.getElementById('listDiv').innerHTML = result.content;
    document.forms['theForm'].elements['option_name'].value = '';
    document.forms['theForm'].elements['option_name'].focus();
  }

  if (result.message.length > 0)
  {
    alert(result.message);
  }
}

</script>

{include file="pagefooter.tpl"}
{/if}
