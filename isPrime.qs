open Microsoft.Quantum.Canon;

	//"isPrimePositive" is a function that checks if a positive integer greater than 1 
	//is prime or not. As a convention, the integer 1 is not considered a prime number.
    
    function isPrimePositive (n:Int) : (String) 
	{
        
		   mutable test = 0;

		   if (n == 2)
		   {
		   	   return "True";
		   }

		   if (2 < n)
		   {
		   	   for (i in 2 .. n - 1)
			   {
			   	   if (n % i == 0)
				   {
				   	   set test = i;
				   }
			   }

			   
		   }

		    if (test == 0)
			{
				return "True";
			}
			else
			{
				return "False";
			}

		   
		
    }

	//"isPrime" checks if any integer different from -1, 0, 1 is prime or not. Note that we use
	//the theorem that a positive integer n is prime if and only if -n is prime. 

	function isPrime (m:Int) : (String)
	{
	
	        
		
			if (m > 1)
			{
				return isPrimePositive(m);
			}

			if (m < -1)
			{
				return isPrimePositive(-m);
			}

			else
			{
			    return "Not to be considered.";
			}


		
		
	
	}
