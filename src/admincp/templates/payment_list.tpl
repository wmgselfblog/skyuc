{include file="pageheader.tpl"}
{insert_scripts files="skyuc_listtable.js"}
<!-- start payment list -->
<div class="list-div" id="listDiv">
<table cellspacing='1' cellpadding='3'>
  <tr>
    <th>{$lang.payment_name}</th>
    <th width="40%">{$lang.payment_desc}</th>
    <th>{$lang.version}</th>
    <th>{$lang.payment_author}</th>
    <th>{$lang.short_pay_fee}</th>
    <th>{$lang.sort_order}</th>
    <th>{$lang.handler}</th>
  </tr>
  {foreach from=$modules item=module}
  <tr>
    <td class="first-cell" valign="top">
      {if $module.install == 1}
        <span onclick="listTable.edit(this, 'edit_name', '{$module.code}'); return false;">{$module.name}</span>
      {else}
        {$module.name}
      {/if}
    </td>
    <td>{$module.desc|nl2br}</td>
    <td valign="top">{$module.version}</td>
    <td valign="top"><a href="{$module.website}" target="_blank">{$module.author}</a></td>
    <td valign="top" align="right">
      {if $module.is_cod}
        {if $module.install == 1}
          <span onclick="listTable.edit(this, 'edit_pay_fee', '{$module.code}'); return false;">{$module.pay_fee}</span>
        {else}
          {$module.pay_fee}
        {/if}
	 {else}{$lang.decide_by_ship}
      {/if}
    </td>
    <td align="right" valign="top"> {if $module.install == 1} <span onclick="listTable.edit(this, 'edit_order', '{$module.code}'); return false;">{$module.pay_order}</span> {else} &nbsp; {/if} </td>
    <td align="center" valign="top">
      {if $module.install == "1"}
        <a href="javascript:confirm_redirect(lang_removeconfirm, 'payment.php?act=uninstall&code={$module.code}')">{$lang.uninstall}</a>
        <a href="payment.php?act=edit&code={$module.code}">{$lang.edit}</a>
      {else}
        <a href="payment.php?act=install&code={$module.code}">{$lang.install}</a>
      {/if}
    </td>
  </tr>
  {/foreach}
</table>
</div>
<!-- end payment list -->
{include file="pagefooter.tpl"}