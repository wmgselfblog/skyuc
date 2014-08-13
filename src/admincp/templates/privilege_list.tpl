{if $full_page}
{include file="pageheader.tpl"}
{insert_scripts files="skyuc_listtable.js"}

<div class="list-div" id="listDiv">
{/if}

<table cellspacing='1' cellpadding='3' id='list-table'>
  <tr>
    <th>{$lang.user_name}</th>
    <th>{$lang.email}</th>
    <th>{$lang.join_time}</th>
    <th>{$lang.last_time}</th>
    <th>{$lang.handler}</th>
  </tr>
  {foreach from=$admin_list item=list}
  <tr>
    <td class="first-cell" >{$list.user_name}</td>
    <td align="left">{$list.email}</td>
    <td align="center">{$list.join_time}</td>
    <td align="center">{if $list.last_time eq ""}N/A{else}{$list.last_time}{/if}</td>
    <td align="center">
      <a href="privilege.php?act=allot&id={$list.user_id}&user={$list.user_name}" title="{$lang.allot_priv}"><img src="images/icon_priv.gif" border="0" height="16" width="16"></a>&nbsp;&nbsp;
      <a href="admin_logs.php?act=list&id={$list.user_id}" title="{$lang.view_log}"><img src="images/icon_view.gif" border="0" height="16" width="16"></a>&nbsp;&nbsp;
      <a href="privilege.php?act=edit&id={$list.user_id}" title="{$lang.edit}"><img src="images/icon_edit.gif" border="0" height="16" width="16"></a>&nbsp;&nbsp;
      <a href="javascript:;" onclick="listTable.remove({$list.user_id}, '{$lang.drop_confirm}')" title="{$lang.remove}"><img src="images/icon_drop.gif" border="0" height="16" width="16"></a></td>
  </tr>
  {/foreach}
</table>

{if $full_page}
</div>
{include file="pagefooter.tpl"}
{/if}
