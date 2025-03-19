/**
 * Async fonksiyonlardaki hataları yakalamak için kullanılan yardımcı fonksiyon
 * @param {Function} fn - Async fonksiyon
 * @returns {Function} - Express middleware fonksiyonu
 */
module.exports = fn => {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
};