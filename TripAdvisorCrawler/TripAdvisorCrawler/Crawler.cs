﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HtmlAgilityPack;
using Newtonsoft.Json;
using System.Web;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Support.UI;
using System.Threading;

namespace TripAdvisorCrawler
{
    public class Crawler
    {
        private string seed;
        private string tripadvisor = "https://tripadvisor.com";
        public List<POI> results = new List<POI>();
        public Dictionary<string, User> users = new Dictionary<string, User>();
        public string tripType;
 //       public ChromeDriver driver = new ChromeDriver("C:/Users/User/Documents/AAU/P8Project/TripAdvisorCrawler/TripAdvisorCrawler");
        public ChromeDriver driver = new ChromeDriver("C:/Users/marku/Desktop");
        public HtmlWeb web = new HtmlWeb();
        public HtmlDocument doc;

        public Crawler(string seed)
        {
            this.seed = seed;
            doc = web.Load(seed);
        }

        public void Crawl()
        {
            //ProcessTop10Pages(seed);
            ProcessTop30RestaurantsPage(seed);
        }

        public void ProcessTop10Pages(string pageUrl)
        {

            var ele = doc.GetElementbyId("FILTERED_LIST");
            for (int attIndex = 0; attIndex < 10; attIndex++)
            {

                var e = ele.ChildNodes[1].ChildNodes.Where(x => x.Name == "li").ToList()[attIndex].ChildNodes[1].ChildNodes[2];
                var attLink = e.InnerHtml.Split('\"')[3];

                var poi = ProcessAttraction(attLink);
                ProcessReviews(poi, driver, attLink);

            }
            Console.WriteLine("Done");

        }

        private POI ProcessAttraction(string link)
        {
            //Load attraction page
            var innerDoc = web.Load(tripadvisor + link);
            //Find script containing JSON data about attraction
            var contextScriptNode = innerDoc.DocumentNode.SelectNodes("//script")[1];
            dynamic array = JsonConvert.DeserializeObject(contextScriptNode.InnerHtml);
            //Create new POI and populate from JSON
            POI newPOI = new POI();
            newPOI.name = array["name"];
            newPOI.imgURL = array["image"];
            newPOI.avgRating = Convert.ToDouble(array["aggregateRating"]["ratingValue"]);
            newPOI.address = array["address"]["streetAddress"];
            newPOI.city = array["address"]["addressLocality"];
            newPOI.openingshours = new Dictionary<string, string>();
            //Gets first div with class 'detail' containing the category
            newPOI.category = innerDoc.DocumentNode.SelectNodes("//div[contains(@class,'detail')]")[0].InnerText;
            //Checks for existence of opening times
            var openingExist = innerDoc.DocumentNode.SelectNodes("//div[@class='hoursAll hidden']");
            if (openingExist != null)
            {
                //Adds opening times
                var openingTimesDiv = openingExist[0].ChildNodes[0];
                for (int i = 0; i < openingTimesDiv.ChildNodes.Count; i++)
                {
                    newPOI.openingshours.Add(openingTimesDiv.ChildNodes[i].InnerText, openingTimesDiv.ChildNodes[i + 1].InnerText);
                    i++;
                }
            }
            return newPOI;
        }

        private void ProcessReviews(POI newPOI, ChromeDriver driver, string attractionLink)
        {
            newPOI.reviews = new List<Review>();            
            //Review handling
            var noPages = 1;
            var alteredDoc = new HtmlDocument();
            //Go to attraction page
            driver.Navigate().GoToUrl(tripadvisor + attractionLink);
            //Check language box for all languages
            var languageCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[4]/div/div[2]/div[1]/div[1]/label");
            languageCheckBox.Click();
            Thread.Sleep(3000);
            IWebElement tripCheckBox = null;
            
            for (int i = 0; i < 5; i++)
            {
                if (i == 0)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[1]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "family";
                }
                else if (i == 1)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[1]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[2]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "couple";
                }
                else if (i == 2)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[2]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[3]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "alone";
                }
                else if (i == 3)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[3]/label");

                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[4]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "business";
                }
                else if (i == 4)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[4]/label");

                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_ar_responsive_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[5]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "friends";
                }

                alteredDoc.LoadHtml(driver.PageSource);

                var pageNode = alteredDoc.DocumentNode.SelectNodes("//a[contains(@class, 'pageNum last taLnk')]")[0];
                noPages = Convert.ToInt32(pageNode.InnerText);
                noPages = 2;

                for (int h = 0; h < noPages; h++)
                {
                    if (h != 0)
                    {
                        var insIndex = attractionLink.IndexOf("Reviews") + 8;
                        attractionLink = attractionLink.Insert(insIndex, "or" + h * 10 + "-");
                        driver.Navigate().GoToUrl(tripadvisor + attractionLink);
                    }

                    var reviewNodes = alteredDoc.DocumentNode.SelectNodes("//div[@class='prw_rup prw_reviews_review_resp']");
                    int k = 0;
                    foreach (var item in reviewNodes)
                    {
                        var newReview = new Review();
                        var userID = item.SelectNodes("//div[@class='member_info']")[k].ChildNodes[0].Id.Substring(4).Split('-')[0];
                        if (users.ContainsKey(userID))
                        {
                            users[userID].given_reviews.Add(newReview);
                            newReview.author = users[userID];
                        }
                        else
                        {
                            var newUser = new User();
                            newUser.uid = userID;
                            users.Add(userID, newUser);
                            newUser.given_reviews = new List<Review>();
                            newUser.given_reviews.Add(newReview);
                            newReview.author = newUser;
                        }
                        var spanContainer = item.SelectNodes("//div[contains(@class,'rev_wrap ui_columns is-multiline')]")[k];
                        var rating = Char.GetNumericValue(spanContainer.ChildNodes[1].InnerHtml.Split('_')[3][0]);
                        newReview.rating = rating;
                        newReview.month_visited = item.SelectNodes("//div[@class='prw_rup prw_reviews_stay_date_hsx']")[k].InnerText.Split(':')[1].Trim();
                        
                        newReview.company = tripType;


                        newPOI.reviews.Add(newReview);
                        k++;

                    }
                    Console.WriteLine("Next page");
                    Thread.Sleep(1000);
                }
                Console.WriteLine("Finished triptype: " + tripType);
            }
            Console.WriteLine("Finished attraktion");
            results.Add(newPOI);
            Console.WriteLine("Next attraktion");


        }

        public void ProcessTop30RestaurantsPage(string pageUrl)
        {
            HtmlWeb web = new HtmlWeb();
            HtmlDocument doc = web.Load(pageUrl);
            var ele = doc.GetElementbyId("EATERY_LIST_CONTENTS");

            for (int restIndex = 0; restIndex < 30; restIndex++)
            {
                var e = ele.ChildNodes[1].ChildNodes[11].ChildNodes[1];
                var restLink = e.InnerHtml.Split('\"')[3];

                var poi = ProcessRestaurant(restLink);
                ProcessRestaurantReviews(poi, restLink);
            }
        }

        private POI ProcessRestaurant(string restLink)
        {
            //load restaurant page
            var restaurantPage = web.Load(tripadvisor + restLink);
            //find script containing JSON data about restaurant
            var contextScriptNode = restaurantPage.DocumentNode.SelectNodes("//script")[1];
            dynamic array = JsonConvert.DeserializeObject(contextScriptNode.InnerHtml);
            //create new POI and populate fields
            POI newPOI = new POI();
            newPOI.name = array["name"];
            newPOI.imgURL = array["image"];
            if (array["priceRange"] == "$$ - $$$")
            {
                newPOI.priceLevel = 2;
            }
            else if (array["PriceRange"] == "$$$$")
            {
                newPOI.priceLevel = 3;
            }
            else
            {
                newPOI.priceLevel = 1;
            }
            newPOI.avgRating = Convert.ToDouble(array["aggregateRating"]["ratingValue"]);
            newPOI.address = array["address"]["streetAddress"];
            newPOI.city = array["address"]["addressLocality"];

            //måske ændres
            var headerInfoNode = restaurantPage.GetElementbyId("taplc_resp_rr_top_info_rr_resp_0");
            newPOI.category = headerInfoNode.ChildNodes[0].ChildNodes[2].ChildNodes[2].ChildNodes[0].ChildNodes[2].InnerText;
            newPOI.openingshours = new Dictionary<string, string>();


            driver.Navigate().GoToUrl(tripadvisor + restLink);

            //Opening hours
            var openingHoursButton = driver.FindElementByXPath("//*[@id='component_10']/div/div/div");
            openingHoursButton.Click();

            var openingHoursWindowContents = driver.FindElementById("c_popover_2");
            var openingHours = openingHoursWindowContents.Text.Split('\n').Skip(1).ToList();

            for (int i = 0; i < openingHours.Count(); i = i + 2)
            {
                newPOI.openingshours.Add(openingHours[i], openingHours[i + 1]);
            }

            return newPOI;
        }

        private void ProcessRestaurantReviews(POI newPOI, string restaurantLink)
        {

            newPOI.reviews = new List<Review>();
            //Review handling
            var noPages = 1;
            var alteredDoc = new HtmlDocument();

            
            driver.Navigate().GoToUrl(tripadvisor + restaurantLink);

            //Check language box for all languages
            var languageCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[4]/div/div[2]/div[1]/div[1]/label");
            languageCheckBox.Click();
            Thread.Sleep(3000);
            IWebElement tripCheckBox = null;
            for (int i = 0; i < 5; i++)
            {
                if (i == 0)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[1]");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "family";
                }
                else if (i == 1)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[1]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[2]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "couple";
                }
                else if (i == 2)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[2]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[3]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "alone";
                }
                else if (i == 3)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[3]/label");

                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[4]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "business";
                }
                else if (i == 4)
                {
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[4]/label");

                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripCheckBox = driver.FindElementByXPath("//*[@id='taplc_detail_filters_rr_resp_0']/div/div[1]/div/div[2]/div[2]/div/div[2]/div/div[5]/label");
                    tripCheckBox.Click();
                    Thread.Sleep(3000);
                    tripType = "friends";
                }

                alteredDoc.LoadHtml(driver.PageSource);
                //Find number of pages of reviews
                var pageNode = alteredDoc.DocumentNode.SelectNodes("//a[contains(@class, 'pageNum last taLnk')]")[0];
                noPages = Convert.ToInt32(pageNode.InnerText);
                noPages = 2;

                for (int h = 0; h < noPages; h++)
                {
                    if (h != 0)
                    {
                        var insIndex = restaurantLink.IndexOf("Reviews") + 8;
                        restaurantLink = restaurantLink.Insert(insIndex, "or" + h * 10 + "-");
                        driver.Navigate().GoToUrl(tripadvisor + restaurantLink);
                    }

                    var reviewNodes = alteredDoc.DocumentNode.SelectNodes("//div[@class='prw_rup prw_reviews_review_resp']");
                    int k = 0;
                    foreach (var item in reviewNodes)
                    {
                        var newReview = new Review();
                        var userID = item.SelectNodes("//div[@class='member_info']")[k].ChildNodes[0].Id.Substring(4).Split('-')[0];
                        if (users.ContainsKey(userID))
                        {
                            users[userID].given_reviews.Add(newReview);
                            newReview.author = users[userID];
                        }
                        else
                        {
                            var newUser = new User();
                            newUser.uid = userID;
                            users.Add(userID, newUser);
                            newUser.given_reviews = new List<Review>();
                            newUser.given_reviews.Add(newReview);
                            newReview.author = newUser;
                        }
                        var spanContainer = item.SelectNodes("//div[contains(@class,'rev_wrap ui_columns is-multiline')]")[k];
                        var rating = Char.GetNumericValue(spanContainer.ChildNodes[1].InnerHtml.Split('_')[3][0]);
                        newReview.rating = rating;
                        newReview.month_visited = item.SelectNodes("//div[@class='prw_rup prw_reviews_stay_date_hsx']")[k].InnerText.Split(':')[1].Trim();
                        newReview.company = tripType;

                        

                        newPOI.reviews.Add(newReview);
                        k++;

                    }
                    Console.WriteLine("Next page");
                    Thread.Sleep(1000);
                }
                Console.WriteLine("Finished triptype: " + tripType);



            }
            Console.WriteLine("Finished attraktion");
            results.Add(newPOI);
            Console.WriteLine("Next attraktion");



        }

    }
}
