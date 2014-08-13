{if $full_page}
{include file="pageheader.tpl"}
{insert_scripts files="skyuc_listtable.js"}
<div class="form-div">
  <form action="javascript:searchComment()" name="searchForm">
    <img src="images/icon_search.gif" width="26" height="22" border="0" alt="SEARCH" />
    {$lang.search_comment} <input type="text"  name="keyword" /> <input type="submit" class="button primary submitButton" value="{$lang.button_search}"  />
  </form>
</div>

<form method="POST" action="comment_manage.php?act=batch_drop" name="listForm"  onsubmit="return confirm_bath()">

<!-- start comment list -->
<div class="list-div" id="listDiv">
{/if}

<table cellpadding="3" cellspacing="1">
  <tr>
    <th>
      <input onclick='listTable.selectAll(this, "checkboxes")' type="checkbox">
      <a href="javascript:listTable.sort('comment_id'); ">{$lang.record_id}</a> {$sort_comment_id}</th>
    <th><a href="javascript:listTable.sort('user_name'); ">{$lang.user_name}</a>{$sort_user_name}</th>
    <th><a href="javascript:listTable.sort('comment_type'); ">{$lang.comment_type}</a>{$sort_comment_type}</th>
    <th><a href="javascript:listTable.sort('id_value'); ">{$lang.comment_obj}</a>{$sort_id_value}</th>
    <th><a href="javascript:listTable.sort('ip_address'); ">{$lang.ip_address}</a>{$sort_ip_address}</th>
    <th><a href="javascript:listTable.sort('add_time'); ">{$lang.comment_time}</a>{$sort_add_time}</th>
    <th>{$lang.comment_flag}</th>
	<th>{$lang.content}</th>
    <th>{$lang.handler}</th>
  </tr>
  {foreach from=$comment_list item=comment}
  <tr>
    <td><input value="{$comment.comment_id}" name="checkboxes[]" type="checkbox">{$comment.comment_id}</td>
    <td>{$comment.user_name}</td>
    <td>{$lang.type[$comment.comment_type]}</td>
    <td><a href="../{if $comment.comment_type eq '0'}show{else}article{/if}.php?id={$comment.id_value}" target="_blank">{$comment.title}</td>
    <td>{$comment.ip_address}</td>
    <td align="center">{$comment.add_time}</td>
    <td align="center">{$comment.is_reply}</td>
	<td>{$comment.content|truncate:30:true}</td>
    <td align="center">
      <a href="comment_manage.php?act=reply&amp;id={$comment.comment_id}" title="{$comment.content|truncate:100|escape:html}">{$lang.view_content}</a> |
      <a href="javascript:" onclick="listTable.remove({$comment.comment_id}, '{$lang.drop_confirm}')">{$lang.remove}</a>
    </td>
  </tr>
    {foreachelse}
    <tr><td class="no-records" colspan="10">{$lang.no_records}</td></tr>
    {/foreach}
  </table>

  <table cellpadding="4" cellspacing="0">
    <tr>
      <td>
      <div>
      <select class="textCtrl"  name="sel_action">
        <option value="remove">{$lang.drop_select}</option>
        <option value="allow">{$lang.allow}</option>
        <option value="deny">{$lang.forbid}</option>
      </select>
      <input type="hidden" name="act" value="batch" />
      <input type="submit" class="button primary submitButton" name="drop" id="btnSubmit" value="{$lang.button_submit}"  disabled="true" /></div></td>
      <td align="right">{include file="page.tpl"}</td>
    </tr>
  </table>

{if $full_page}
</div>
<!-- end comment list -->

</form>
<script type="text/javascript" language="JavaScript">
<!--
  listTable.recordCount = {$record_count};
  listTable.pageCount = {$page_count};
  cfm = new Object();
  cfm['allow'] = '{$lang.cfm_allow}';
  cfm['remove'] = '{$lang.cfm_remove}';
  cfm['deny'] = '{$lang.cfm_deny}';

  {foreach from=$filter item=item key=key}
  listTable.filter.{$key} = '{$item}';
  {/foreach}


  /**
   * 搜索评论
   */
  function searchComment()
  {
      var keyword = Utils.trim(document.forms['searchForm'].elements['keyword'].value);
      if (keyword.length > 0)
      {
        listTable.filter['keywords'] = keyword;
        listTable.filter.page = 1;
        listTable.loadList();
      }
      else
      {
          document.forms['searchForm'].elements['keyword'].focus();
      }
  }


   function confirm_bath()
  {
    var action = document.forms['listForm'].elements['sel_action'].value;

    return confirm(cfm[action]);
  }

//-->
</script>
{include file="pagefooter.tpl"}
{/if}
