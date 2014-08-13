{include file="pageheader.tpl"}
<!-- start integrate setup form -->
<div class="list-div" id="listDiv">
  <table cellpadding="3" cellspacing="1">
    <tr><th>{$lang.task_name}</th><th>{$lang.task_status}</th></tr>
    {foreach from=$tasks item=task}
    <tr>
      <td>{$task.task_name}</td>
      <td>{$task.task_status}</td>
    </tr>
    {/foreach}
    <tr>
    <td colspan="2">&nbsp;</span>
    </tr>
    <tr>
    <td colspan="2">{$lang.sync_size}&nbsp;&nbsp;<input type="text" name="size" size="5" value="{$size}" id="SKYUC_SIZE"></td>
    </tr>
    <tr>
    <td colspan="2">
      <input type="button" class="button"  value="{$lang.button_pre}"  onclick="location.href='integrate.php?act=modify'">
      <input type="button" class="button"  value="{$lang.start_task}"  onclick="sync_start(this)">
    </tr>
  </table>
</div>
<!-- end integrate setup form -->
{insert_scripts files="skyuc_validator.js"}
{literal}
<script language="JavaScript">
<!--
function sync_start(obj)
{
  var size_obj = document.getElementById('SKYUC_SIZE');
  var size = parseInt(size_obj.value);

  obj.disabled = true;
  Ajax.call('integrate.php?act=task', 'size=' + size, taskResponse, 'GET', 'JSON');
}

function taskResponse(result)
{
  if (result.message.length > 0)
  {
    alert(result.message);
  }
  if (result.error == 0)
  {
    if (result.id.length > 0)
    {
      $(result.id).innerHTML = result.content;
    }
    if (result.end)
    {
      location.href = 'integrate.php?act=complete';
    }
    else
    {
      Ajax.call('integrate.php?act=task', 'size=' + result.size, taskResponse, 'GET', 'JSON');
    }
  }
}
//-->
</script>
{/literal}
{include file="pagefooter.tpl"}
