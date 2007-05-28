#   $Id: 60-distribution.t,v 1.1 2007-05-28 17:11:41 adam Exp $

use Test::More;
BEGIN {
    eval { require Test::Distribution; };
    if($@) {
        plan skip_all => 'Test::Distribution not installed';
    }
    else {
        import Test::Distribution;
    }
};
