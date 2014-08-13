{include file="pageheader.tpl"}
{insert_scripts files="skyuc_validator.js"}
<div class="list-div" id="listDiv">

<table cellspacing='1' cellpadding='3' id='list-table'>
  <tr>
    <th>{$lang.item}</th>
    <th>{$lang.read}</th>
    <th>{$lang.write}</th>
    <th>{$lang.modify}</th>
  </tr>
  {foreach from=$list item=item key=key}
  <tr>
    <td width="250px">{$item.item}</td>
    <td>{if $item.r > 0}<img src="images/yes.gif" width="14" height="14" alt="YES" />{else}<img src="images/no.gif" width="14" height="14" alt="NO" />{if $item.err_msg.w}&nbsp;<a href="javascript:showNotice('r_{$key}');" title="{$lang.detail}">[{$lang.detail}]</a><br /><span class="notice-span" id="r_{$key}">{foreach from=$item.err_msg.r item=msg}{$msg}{$lang.unread}<br />{/foreach}</span>{/if}{/if}</td>
    <td>{if $item.w > 0}<img src="images/yes.gif" width="14" height="14" alt="YES" />{else}<img src="images/no.gif" width="14" height="14" alt="NO" />{if $item.err_msg.w}&nbsp;<a href="javascript:showNotice('w_{$key}');" title="{$lang.detail}">[{$lang.detail}]</a><br /><span class="notice-span" id="w_{$key}">{foreach from=$item.err_msg.w item=msg}{$msg}{$lang.unwrite}<br />{/foreach}</span>{/if}{/if}</td>
    <td>{if $item.m > 0}<img src="images/yes.gif" width="14" height="14" alt="YES" />{else}<img src="images/no.gif" width="14" height="14" alt="NO" />{if $item.err_msg.m}&nbsp;<a href="javascript:showNotice('m_{$key}');" title="{$lang.detail}">[{$lang.detail}]</a><br /><span class="notice-span" id="m_{$key}">{foreach from=$item.err_msg.m item=msg}{$msg}{$lang.unmodify}<br />{/foreach}</span>{/if}{/if}</td>
  </tr>
  {/foreach}
  {if $tpl_msg}
  <tr>
    <td colspan="4"><img src="images/no.gif" width="14" height="14" alt="NO" /><span style="color:red">{$tpl_msg}</span>{$lang.unrename}</td>
  </tr>
  {/if}
</table>

</div>
{include file="pagefooter.tpl"}