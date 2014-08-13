{if $full_page}
{include file="pageheader.tpl"}
{insert_scripts files="skyuc_listtable.js"}

<form method="post" action="" name="listForm">
<!-- start ads list -->
<div class="list-div" id="listDiv">
{/if}

<table cellpadding="3" cellspacing="1">
  <tr>
    <th><a href="javascript:listTable.sort('ad_name'); ">{$lang.ad_name}</a>{$sort_ad_name}</th>
    <th><a href="javascript:listTable.sort('position_id'); ">{$lang.position_id}</a>{$sort_position_id}</th>
    <th><a href="javascript:listTable.sort('media_type'); ">{$lang.media_type}</a>{$sort_media_type}</th>
    <th><a href="javascript:listTable.sort('start_date'); ">{$lang.start_date}</a>{$sort_start_date}</th>
    <th><a href="javascript:listTable.sort('end_date'); ">{$lang.end_date}</a>{$sort_end_date}</th>
    <th><a href="javascript:listTable.sort('click_count'); ">{$lang.click_count}</a>{$sort_click_count}</th>
	<th>{$lang.enabled}</th>
    <th>{$lang.handler}</th>
  </tr>
  {foreach from=$ads_list item=list}
  <tr>
    <td class="first-cell">
    <span onclick="javascript:listTable.edit(this, 'edit_ad_name', {$list.ad_id})">{$list.ad_name|escape:html}</span>
    </td>
    <td align="left"><span>{if $list.position_id eq 0}{$lang.outside_posit}{else}{$list.position_name}{/if}</span>
    </td>
    <td align="left"><span>{$list.type}</span></td>
    <td align="center"><span>{$list.start_date}</span></td>
    <td align="center"><span>{$list.end_date}</span></td>
    <td align="right"><span>{$list.click_count}</span></td>
	<td align="center"><img src="images/{if $list.enabled}yes{else}no{/if}.gif" onclick="listTable.toggle(this, 'toggle_enabled', {$list.ad_id})" /></td>
    <td align="right"><span>
      {if $list.position_id eq 0}
      <a href="ads.php?act=add_js&type={$list.media_type}&id={$list.ad_id}" title="{$lang.add_js_code}"><img src="images/icon_js.gif" border="0" height="16" width="16" /></a>
      {/if}
      <a href="ads.php?act=edit&id={$list.ad_id}" title="{$lang.edit}"><img src="images/icon_edit.gif" border="0" height="16" width="16" /></a>
      <a href="javascript:;" onclick="listTable.remove({$list.ad_id}, '{$lang.drop_confirm}')" title="{$lang.remove}"><img src="images/icon_drop.gif" border="0" height="16" width="16" /></a></span>
    </td>
  </tr>
  {foreachelse}
    <tr><td class="no-records" colspan="10">{$lang.no_ads}</td></tr>
  {/foreach}
  <tr>
    <td align="right" nowrap="true" colspan="10">{include file="page.tpl"}</td>
  </tr>
</table>

{if $full_page}
</div>
<!-- end ad_position list -->
</form>

<script type="text/javascript" language="JavaScript">
  listTable.recordCount = {$record_count};
  listTable.pageCount = {$page_count};

  {foreach from=$filter item=item key=key}
  listTable.filter.{$key} = '{$item}';
  {/foreach}
</script>
{include file="pagefooter.tpl"}
{/if}