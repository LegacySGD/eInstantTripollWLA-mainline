<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,retrievePrizeTable,getType">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFeed = [];
					var debugFlag = false;
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{
						var scenario = getScenario(jsonContext);
						var prizes = getPrizes(scenario);
						var winningTotals = getWinningTotals(scenario);
						var playNumbers = getPlayNumbers(scenario);
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');

						var r = [];

						// Output outcome numbers table.
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
 						r.push('<tr>');
							r.push('<td class="tablehead" width="34%">');
							r.push(getTranslationByName("row", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="8%">');
							r.push(getTranslationByName("dice1", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="8%">');
							r.push(getTranslationByName("dice2", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="8%">');
							r.push(getTranslationByName("dice3", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="12%">');
							r.push(getTranslationByName("rolledNumber", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="12%">');
							r.push(getTranslationByName("targetNumber", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="12%">');
							r.push(getTranslationByName("attachedPrize", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="12%">');
							r.push(getTranslationByName("multiplierApplied", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="12%">');
							r.push(getTranslationByName("winRow", translations));
							r.push('</td>');

								r.push('</tr>');
							
						var rolledNumber = 0;
						var winRow = false;

						for(var i = 0; i < prizes.length; ++i)
							{
							rolledNumber = (parseInt(playNumbers[i][0]) + parseInt(playNumbers[i][1]) +  parseInt(playNumbers[i][2]));
							winRow = (rolledNumber == winningTotals[i]);
									r.push('<tr>');

								r.push('<td class="tablebody">');
								r.push(getTranslationByName("rowColour"+String(i+1), translations));
								r.push('</td>');

								r.push('<td class="tablebody">');
								r.push(playNumbers[i][0]);
								r.push('</td>');

								r.push('<td class="tablebody">');
								r.push(playNumbers[i][1]);
								r.push('</td>');

								r.push('<td class="tablebody">');
								r.push(playNumbers[i][2]);
								r.push('</td>');

								r.push('<td class="tablebody">');
								r.push(String(rolledNumber));
								r.push('</td>');

								r.push('<td class="tablebody">');
								r.push(winningTotals[i]);
								r.push('</td>');

								r.push('<td class="tablebody">');
								r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames,prizes[i])]);
								r.push('</td>');

								// calculate if the dice are repeated and if so how many times
								var repeatCount = getRepeatCount(playNumbers[i]);
								r.push('<td class="tablebody">');
								if(repeatCount > 1)
											{
									r.push(repeatCount + "x");
											}
								r.push('</td>');

								r.push('<td class="tablebody">');
								r.push((winRow) ? getTranslationByName("wins", translations) : '');
								r.push('</td>');

								// Calculate sub total for display later
								//if(winningTotals[i] == (parseInt(playNumbers[i][0]) + parseInt(playNumbers[i][1]) + parseInt(playNumbers[i][2])))
								//{
								//	totalWin = totalWin + (getPrizeAsFloat(convertedPrizeValues[getPrizeNameIndex(prizeNames,prizes[i])]) * repeatCount);
								//}
									r.push('</tr>');
								}
						r.push('</table>');

						//r.push('<table border="0" cellpadding="2" cellspacing="1" width="24%" class="gameDetailsTable" style="table-layout:fixed">');
 						//r.push('<tr>');

						//	r.push('<td class="tablehead" width="16%">');
						//	r.push(getTranslationByName("totalWin", translations));
						//	r.push('</td>');

						//	var poundSymbol = getPoundSymbol(convertedPrizeValues[0]);
						//	r.push('<td class="tablehead" width="8%">');
						//	r.push(poundSymbol + totalWin.toFixed(2));
						//	r.push('</td>');

 						//r.push('</tr>');
						//r.push('</table>');

						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
 						{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
 							r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
 							r.push('</td>');
 						r.push('</tr>');
							}
						r.push('</table>');
						}
						return r.join('');
					}

					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeStructures, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeStructStrings = prizeStructures.split("|");


						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeStructStrings[i];
							}
						}

						return "";
					}

					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}

					// Input: "B,4,241|F,10,345|D,13,516|A,3,111|E,9,353|C,7,432"
					// Output: ["B","F","D","A","E","C"]
					function getPrizes(scenario)
					{
						var result = [];
						var numsData = scenario.split("|");
						for(var i = 0; i < numsData.length; ++i)
					{
							result.push(numsData[i].split(",")[0]);
						}
						return result;
					}

					// Input: "B,4,241|F,10,345|D,13,516|A,3,111|E,9,353|C,7,432"
					// Output: ["4","10","13","3","9","7"]
					function getWinningTotals(scenario)
					{
						var result = [];
						var numsData = scenario.split("|");
						for(var i = 0; i < numsData.length; ++i)
						{
							result.push(numsData[i].split(",")[1]);
						}
						return result;
					}

					// Input: "B,4,241|F,10,345|D,13,516|A,3,111|E,9,353|C,7,432"
					// Output: ["241","345","516","111","353","432"]
					function getPlayNumbers(scenario)
					{
						var result = [];
						var numsData = scenario.split("|");
						for(var i = 0; i < numsData.length; ++i)
						{
							result.push(numsData[i].split(",")[2]);
						}
						return result;
					}

					// Input: "111"
					// Output: 3
					function getRepeatCount(roundPlayNumbers)
					{
						var repeatCounter = 0;
						if(parseInt(roundPlayNumbers[0]) == parseInt(roundPlayNumbers[1]))
						{
							++repeatCounter;
						}
						if(parseInt(roundPlayNumbers[0]) == parseInt(roundPlayNumbers[2]))
						{
							++repeatCounter;
						}
						if(parseInt(roundPlayNumbers[1]) == parseInt(roundPlayNumbers[2]))
						{
							++repeatCounter;
						}
						if(repeatCounter != 3)
							{
							++repeatCounter;
							}
						return repeatCounter;
						}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["23", "9", "31"]
					function getWinningNumbers(scenario)
					{
						var numsData = scenario.split("|")[0];
						return numsData.split(",");
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["8", "35", "4", "13", ...] or ["E", "E", "D", "G", ...]
					function getOutcomeData(scenario, index)
					{
						var outcomeData = scenario.split("|")[1];
						var outcomePairs = outcomeData.split(",");
						var result = [];
						for(var i = 0; i < outcomePairs.length; ++i)
					{
							result.push(outcomePairs[i].split(":")[index]);
						}
						return result;
					}

					// Input: 'X', 'E', or number (e.g. '23')
					// Output: translated text or number.
					function translateOutcomeNumber(outcomeNum, translations)
					{
						if(outcomeNum == 'Z')
						{
							return getTranslationByName("winAll", translations);
						}
						else
						{
							return outcomeNum;
						}
					}

					// Update prize to float format string
					function getPrizeAsFloat(prize)
					{
						var prizeFloat = parseFloat(prize.replace(/[^0-9-.]/g, ''));
						return prizeFloat;
					}

					// strip all other symbols except £,$ etc.
					function getPoundSymbol(prize)
					{
						var prizeSymb = prize.replace(/[0-9-,.]/g, '');
						return prizeSymb;
					}

					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i < winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum || boardNum == "Z")
							{
								return true;
							}
						}
						return false;
					}

					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}

					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="convertedPrizeValues">

					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
